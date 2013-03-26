require 'models/blueprints/control'

module Dev
    module Controldev
        device_type 'Joystick' do
            provides Base::Motion2DControllerSrv
        end
        device_type 'CANJoystick' do
            provides Base::Motion2DControllerSrv
        end

        Base::ControlLoop.declare 'FourWheel', 'controldev/FourWheelCommand'

        device_type 'Sliderbox' do
            provides Base::FourWheelControllerSrv
        end

        device_type 'CANSliderbox' do
            provides Base::FourWheelControllerSrv
        end
        
        device_type 'Mouse3D' do
        end
    end
end

class Controldev::Mouse3DTask
    driver_for Dev::Controldev::Mouse3D, :as => 'mouse3d'
end

class Controldev::Remote
    driver_for Dev::Controldev::CANJoystick, :as => 'joystick'
    driver_for Dev::Controldev::CANSliderbox, :as => 'sliderbox'
end

class Controldev::SliderboxTask
    driver_for Dev::Controldev::Sliderbox, :as => 'sliderbox'
end

class Controldev::JoystickTask
    driver_for Dev::Controldev::Joystick, :as => 'joystick'
end

