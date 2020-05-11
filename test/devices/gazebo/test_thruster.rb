# frozen_string_literal: true

require "models/devices/gazebo/thruster"

module CommonModels
    module Devices
        module Gazebo
            describe Thruster do
                # # What one usually wants to test for a Device would be the
                # # extensions module.
                # it "allows to specify the baudrate" do
                #     dev = syskit_stub_device(Thruster)
                #     dev.baudrate(1_000_000) # 1Mbit
                #     assert_equal 1_000_000, dev.baudrate
                # end
            end
        end
    end
end
