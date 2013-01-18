require 'models/blueprints/sensors'
Dev::Sensors.device_type 'SickLMS' do
    provides Base::LaserRangeFinderSrv
end

class LaserscannerSick::Task
    driver_for Dev::Sensors::SickLMS, :as => 'device'
end
