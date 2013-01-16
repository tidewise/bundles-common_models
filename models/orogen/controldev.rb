require 'models/blueprints/control'

module Dev
    module Controldev
        device_type 'Joystick' do
            provides Rock::Base::Motion2DControllerSrv
        end
        device_type 'CANJoystick' do
            provides Rock::Base::Motion2DControllerSrv
        end

        Rock::Base::ControlLoop.declare 'FourWheel', 'controldev/FourWheelCommand'

        device_type 'Sliderbox' do
            provides Rock::Base::FourWheelControllerSrv
        end

        device_type 'CANSliderbox' do
            provides Rock::Base::FourWheelControllerSrv
        end
    end
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

