require 'models/blueprints/sensors'
Dev::Sensors.device_type 'Hokuyo' do
    provides Dev::Sensors::LaserRangeFinder
end

class Hokuyo::Task
    driver_for Dev::Sensors::Hokuyo
    provides Rock::Base::TimestampInputSrv
end

