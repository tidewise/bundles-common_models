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
    def define_simulated_device(name, model, options = Hash.new)
        robot.device model, :as => name
        define name, Simulated::getSensor(model.name,options) #composition_from_device_type(model)#.use(mars_dev)
    end
end

module Simulated
    

    class Servo < Syskit::Composition
        add Simulation::Mars, :as => "mars"
        add Simulation::MarsServo, :as => "task"
    end
    
    class Actuator < Syskit::Composition
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
    
    class Camera < Syskit::Composition
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
    
    class IMU < Syskit::Composition
        add Simulation::Mars, :as => "mars"
        add Simulation::MarsIMU, :as => "task"

        task_child.each_output_port do |port|
            export port
        end

        provides Base::OrientationSrv, :as => 'orientation'
        provides Base::OrientationWithZSrv, "orientation_z_samples" => "orientation_samples", :as => 'orientation_with_z'
        provides Base::ZProviderSrv, :as => 'z_samples', 'z_samples' => "pose_samples"

    end

    def self.getSensor(name,options = nil)
        constants.each do |c|
            c = eval(c)
            if c < Syskit::Composition
                a = c.task_child.model
                b = name
                if a.fullfills?(eval(b))
                    options.each_pair do |key,value|
                        eval("c.task_child.#{key}(#{value})")
                    end
                    return c
                end
            end
        end
        raise ArgumentError, "No composition found that represent an #{name} for the simulation"
    end
end

