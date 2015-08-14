require 'rock/models/devices/input/joystick'

class OroGen::Controldev::JoystickTask
    driver_for Rock::Devices::Input::Joystick, as: 'driver'
end

