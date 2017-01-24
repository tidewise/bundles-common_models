require 'rock/models/devices/gazebo/entity'
require 'rock/models/services/transformation'

module Rock
    module Devices
        module Gazebo
            device_type 'Link' do
                provides Entity

                output_port 'link_state_samples', '/base/samples/RigidBodyState'

                provides Rock::Services::Pose,
                    'pose_samples' => 'link_state_samples'
                provides Rock::Services::Transformation,
                    'transformation' => 'link_state_samples'
                provides Rock::Services::Velocity,
                    'velocity_samples' => 'link_state_samples'
            end
        end
    end
end
