require 'models/blueprints/devices'

class CameraAravis::Task
    driver_for Dev::Sensors::Cameras::Aravis, :as => 'driver'

    def configure
        super
        if p = robot_device.period
            orocos_task.fps = (1.0 / p).round
        end
    end
end
