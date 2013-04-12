require 'models/blueprints/devices'
require 'models/blueprints/timestamping'

class Hokuyo::Task
    driver_for Dev::Sensors::Hokuyo, :as => 'driver'
    provides Base::TimestampInputSrv, :as => 'timestamps'

    transformer do
        associate_frame_to_ports 'laser', 'scans'
    end
end

