require 'models/blueprints/sensors'
require 'models/blueprints/timestamping'
Dev::Sensors.device_type 'Hokuyo' do
    provides Dev::Sensors::LaserRangeFinder
end

class Hokuyo::Task
    driver_for Dev::Sensors::Hokuyo, :as => 'driver'
    provides Base::TimestampInputSrv, :as => 'timestamps'
end

