require 'rock/models/services/joints_control_loop'
require 'rock/models/services/pose'

module Rock
    module Devices
        module Gazebo
            device_type 'Model' do
                provides Rock::Services::Pose
                provides Rock::Services::JointsControlledSystem
            end
        end
    end
end
