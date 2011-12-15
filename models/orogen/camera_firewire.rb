class CameraFirewire::CameraTask
    driver_for 'CameraFirewire'
    provides Srv::TimestampInput

    def configure
        super
        if p = robot_device.period
            orogen_task.fps = (1.0 / p).round
        end
    end
end

