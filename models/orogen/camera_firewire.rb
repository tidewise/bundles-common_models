class CameraFirewire::CameraTask
    driver_for 'CameraFirewire'
    provides Srv::TimestampInput
    provides Srv::ImageProvider
    
    def configure
        super
        if p = robot_device.period
            orogen_task.fps = (1.0 / p).round
        end
    end
    
end

