require 'models/blueprints/pose'


using_task_library 'simulation'


Dev::Simulation.device_type "Servo"
Dev::Simulation.device_type "Camera"
Dev::Simulation.device_type "DepthCamera"
Dev::Simulation.device_type "MarsActuator"

Dev::Simulation.device_type "Actuator" 

Dev::Simulation.device_type "Joint"
Dev::Simulation.device_type "RangeFinder"

Dev::Simulation.device_type "IMU"
Dev::Simulation.device_type "Sonar"


class Simulation::Mars
    def configure
        orocos_task.enable_gui = true
        super
    end

end

class Simulation::MarsServo 
    driver_for Dev::Simulation::Servo, :as => "driver"
end

class Simulation::MarsIMU
    driver_for Dev::Simulation::IMU, :as => 'driver'
end

class Simulation::Sonar
    driver_for Dev::Simulation::Sonar, :as => "driver"
end

class Simulation::MarsCamera
    driver_for Dev::Simulation::Camera, :as => "driver"
end

class Simulation::Actuators
    driver_for Dev::Simulation::Actuator, :as => "driver"
end

class Syskit::Actions::Profile
    #
    # Instead of doing
    #   define 'dynamixel', Model
    #
    # Do
    #
    #   define_simulated_device 'dynamixel', Dev::Simulation::Sonar
    #
    def define_simulated_device(name, model, &block)
        Simulated.define_simulated_device(self, name, model, &block)
    end
end

module Simulated
    def self.define_simulated_device(profile, name, model)
        device = profile.robot.device model, :as => name
        # The SimulatedDevice subclasses expect the MARS task,not the device
        # model. Resolve the task from the device definition by removing the
        # data service selection (#to_component_model)
        #
        # to_instance_requirements is there to convert the device object into
        # an InstanceRequirements object
        device = device.to_instance_requirements.to_component_model
        composition = Simulated.composition_from_device(model)
        device = yield(device) if block_given?
        composition = composition.use('task' => device)
        profile.define name, composition
        model
    end

    def self.composition_from_device(device_model, options = nil)
        SimulatedDevice.each_submodel do |cmp_m|
            if cmp_m.task_child.fullfills?(device_model)
                return cmp_m
            end
        end
        raise ArgumentError, "no composition found to represent devices of type #{device_model} in MARS"
    end
    
    class SimulatedDevice < Syskit::Composition
    end

    class Servo < SimulatedDevice
        add Simulation::Mars, :as => "mars"
        add Simulation::MarsServo, :as => "task"
    end
    
    class Actuator < SimulatedDevice
        add Simulation::Mars, :as => "mars"
        add Simulation::Actuators, :as => "task"
        
        task_child.each_output_port do |port|
            export port
        end
        task_child.each_input_port do |port|
            export port
        end
        
        provides Base::ActuatorControlledSystemSrv, :as => 'actuators'
    end
    
    class Camera < SimulatedDevice
        add Simulation::Mars, :as => "mars"
        add Simulation::MarsCamera, :as => "task"
        
        task_child.each_output_port do |port|
            export port
        end
        task_child.each_input_port do |port|
            export port
        end
        
        provides Base::ImageProviderSrv, :as => 'camera'
    end

    #TODO Add missing ones from above like the actuator
    
    class IMU < SimulatedDevice
        add Simulation::Mars, :as => "mars"
        add Simulation::MarsIMU, :as => "task"

        task_child.each_output_port do |port|
            export port
        end

        provides Base::OrientationSrv, :as => 'orientation'
        provides Base::OrientationWithZSrv, "orientation_z_samples" => "orientation_samples", :as => 'orientation_with_z'
        provides Base::ZProviderSrv, :as => 'z_samples', 'z_samples' => "pose_samples"

    end

end

