# frozen_string_literal: true

require "common_models/models/devices/input/joystick"
require "common_models/models/devices/input/graupner/mc20"

Syskit.extend_model OroGen.controldev.JoystickTask do
    driver_for CommonModels::Devices::Input::Joystick, as: "driver"
end
