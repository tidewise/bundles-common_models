require 'rock/models/services/transformation'

module Rock
    module Devices
        module Gazebo
            device_type 'Link' do
                provides Rock::Services::Transformation
            end
        end
    end
end
