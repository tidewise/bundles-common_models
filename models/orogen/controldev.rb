load_system_model 'blueprints/control'

device_type 'Joystick' do
    provides Srv::Motion2DController
end
device_type 'RemoteJoystick' do
    provides Srv::Motion2DController
end

Cmp::ControlLoop.declare 'FourWheel', 'controldev/FourWheelCommand'

device_type 'RemoteSliderbox' do
    provides Srv::FourWheelController
end

class Controldev::Remote
    driver_for Dev::RemoteJoystick, :as => 'joystick'
    driver_for Dev::RemoteSliderbox, :as => 'sliderbox'
end

class Controldev::JoystickTask
    driver_for Dev::Joystick
end

