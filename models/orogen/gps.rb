require 'models/blueprints/devices'
Dev::Sensors.device_type 'MB500' do
    provides Dev::Sensors::GPS
end

class Gps::MB500Task
    driver_for Dev::Sensors::MB500, :as => 'driver'

    def configure
        super

        if Conf.utm_local_origin?
            orogen_task.origin = Conf.utm_local_origin
        end
    end
end

