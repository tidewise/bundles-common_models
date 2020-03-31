# frozen_string_literal: true

require 'common_models/models/devices/gazebo/entity'
require 'common_models/models/services/joints_control_loop'

module CommonModels
    module Devices
        module Gazebo
            device_type 'Joint' do
                provides Entity

                provides Services::JointsControlledSystem
            end
        end
    end
end
