require 'models/devices/gazebo/entity'
require 'models/services/image'

module CommonModels
    module Devices
        module Gazebo
            # Representation of gazebo's 'camera' sensor
            device_type 'Camera' do
                provides Entity
                provides CommonModels::Services::Image
            end
        end
    end
end
