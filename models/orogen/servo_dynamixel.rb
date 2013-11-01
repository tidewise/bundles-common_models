require 'models/blueprints/devices'
class ServoDynamixel::Task
    driver_for Dev::Actuators::Dynamixel, :as => 'driver'

    transformer do
        frames "lower", "upper"
        transform_output "transforms", "lower" => "upper"
    end
end
