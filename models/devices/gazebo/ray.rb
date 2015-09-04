require 'rock/models/services/laser_scan'

module Rock
    module Devices
        module Gazebo
            # Representation of gazebo's 'ray' sensor
            device_type 'Ray' do
                provides Rock::Services::LaserScan
            end
        end
    end
end
