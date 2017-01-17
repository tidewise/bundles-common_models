require 'rock/models/devices/gazebo/entity'
require 'rock/models/services/position'

module Rock
    module Devices
        module Gazebo
            device_type 'GPS' do
                provides Entity
                provides Services::Position
            end
        end
    end
end

