require 'models/devices/gazebo/entity'
require 'models/services/laser_scan'

module CommonModels
    module Devices
        module Gazebo
            # Representation of gazebo's 'ray' sensor
            device_type 'Ray' do
                provides Entity
                provides CommonModels::Services::LaserScan
            end
        end
    end
end
