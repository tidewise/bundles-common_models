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

class Simulated
    class Servo < Syskit::Composition
        add Simulation::Mars, :as => "mars"
        add Simulation::MarsServo, :as => "servo"
    end
    class Actuator < Syskit::Composition
        add Simulation::Mars, :as => "mars"
        add Simulation::Actuators, :as => "actuator"
        
        actuator_child.each_output_port do |port|
            export port
        end
        actuator_child.each_input_port do |port|
            export port
        end
        
        provides Base::ActuatorControlledSystemSrv, :as => 'actuators'
    end

    #TODO Add missing ones from above like the actuator
    
    class IMU < Syskit::Composition
        add Simulation::Mars, :as => "mars"
        add Simulation::MarsIMU, :as => "imu"

        imu_child.each_output_port do |port|
            export port
        end

        provides Base::OrientationSrv, :as => 'orientation'
        provides Base::OrientationWithZSrv, "orientation_z_samples" => "orientation_samples", :as => 'orientation_with_z'
        provides Base::ZProviderSrv, :as => 'z_samples', 'z_samples' => "pose_samples"

    end
end

