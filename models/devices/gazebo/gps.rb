# frozen_string_literal: true

require "common_models/models/devices/gazebo/entity"
require "common_models/models/services/position"
require "common_models/models/services/gps"

module CommonModels
    module Devices
        module Gazebo
            device_type "GPS" do
                provides Entity
                provides Services::Position
                provides Services::GPS
            end
        end
    end
end
