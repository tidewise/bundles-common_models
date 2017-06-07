require 'models/devices/gazebo/entity'
require 'models/services/orientation'
require 'models/services/imu_calibrated_sensors'

module CommonModels
    module Devices
        module Gazebo
            # Representation of gazebo's 'imu' sensor
            device_type 'Imu' do
                provides Entity
                provides CommonModels::Services::Orientation
                provides CommonModels::Services::IMUCalibratedSensors
            end
        end
    end
end
