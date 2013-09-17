require 'models/blueprints/devices'
class ServoDynamixel::Task
    driver_for Dev::Actuators::Dynamixel, :as => 'driver'
end
