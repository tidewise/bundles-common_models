require 'models/devices/gazebo/entity'
require 'models/services/image'

module Rock
    module Devices
        module Gazebo
            # Representation of gazebo's 'camera' sensor
            device_type 'Camera' do
                provides Entity
                provides Rock::Services::Image
            end
        end
    end
end
