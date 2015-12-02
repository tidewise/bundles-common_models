require 'rock/models/services/orientation'

module Rock
    module Devices
        module Gazebo
            # Representation of gazebo's 'imu' sensor
            device_type 'Imu' do
                provides Rock::Services::Orientation
            end
        end
    end
end
