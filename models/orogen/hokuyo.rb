require 'models/blueprints/sensors'
Dev::Sensors.device_type 'Hokuyo' do
    provides Dev::Sensors::LaserRangeFinder
end

class Hokuyo::Task
    driver_for Dev::Sensors::Hokuyo, :as => 'driver'
    provides Rock::Base::TimestampInputSrv, :as => 'timestamps'
end

