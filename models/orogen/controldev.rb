require 'models/devices/input/joystick'
require 'models/devices/input/graupner/mc20'

class OroGen::Controldev::JoystickTask
    driver_for Rock::Devices::Input::Joystick, as: 'driver'
end

class OroGen::Controldev::GraupnerMC20Task
    driver_for Rock::Devices::Input::Graupner::Mc20, as: 'driver'
end
