require 'rock/models/services/pose'

module Rock
    module Devices
        module Gazebo
            device_type 'Model' do
                provides Rock::Services::Pose
            end
        end
    end
end
