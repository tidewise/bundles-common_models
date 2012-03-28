load_system_model 'blueprints/control'

data_service_type 'Joystick' do
    provides Srv::Motion2DController
end
device_type 'Joystick' do
    provides Srv::Joystick
end
device_type 'RemoteJoystick' do
    provides Srv::Joystick
end

Cmp::ControlLoop.declare 'FourWheel', 'controldev/FourWheelCommand'

data_service_type 'Sliderbox' do
    provides Srv::FourWheelController
end

device_type 'Sliderbox' do
    provides Srv::Sliderbox
end

device_type 'RemoteSliderbox' do
    provides Srv::Sliderbox
end

class Controldev::Remote
    driver_for Dev::RemoteJoystick, :as => 'joystick'
    driver_for Dev::RemoteSliderbox, :as => 'sliderbox'
end

class Controldev::SliderboxTask
    driver_for Dev::Sliderbox
end

class Controldev::JoystickTask
    driver_for Dev::Joystick
end

