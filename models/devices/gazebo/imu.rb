require 'rock/models/services/orientation'
require 'rock/models/services/imu_calibrated_sensors'

module Rock
    module Devices
        module Gazebo
            # Representation of gazebo's 'imu' sensor
            device_type 'Imu' do
                provides Rock::Services::Orientation
                provides Rock::Services::IMUCalibratedSensors
            end
        end
    end
end
