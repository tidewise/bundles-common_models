require 'models/blueprints/sensors'
module Dev
    module Camera
        device_type 'Firewire' do
            provides Base::ImageProviderSrv
        end
    end
end

class CameraFirewire::CameraTask
    driver_for Dev::Camera::Firewire, :as => 'driver'
    provides Base::TimestampInputSrv, :as => 'timestamps'
    
    def configure
        super
        if p = robot_device.period
            orogen_task.fps = (1.0 / p).round
        end
    end
end

