device_type 'Joystick' do
    provides Srv::Motion2DCommand
end
device_type 'RemoteJoystick' do
    provides Srv::Motion2DCommand
end
device_type 'RemoteSliderbox' do
    provides Srv::FourWheelCommand
end

class Controldev::Remote
    driver_for Dev::RemoteJoystick, :as => 'joystick'
    driver_for Dev::RemoteSliderbox, :as => 'sliderbox'
end

class Controldev::JoystickTask
    driver_for Dev::Joystick
end

Cmp::ControlLoop.declare 'FourWheel', 'controldev/FourWheelCommand'

