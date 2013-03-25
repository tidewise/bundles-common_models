require 'models/blueprints/control'

using_task_library "controldev"

module Dev
    module Controldev
        device_type 'Joystick' do
            provides Base::Motion2DControllerSrv
        end
        device_type 'CANJoystick' do
            provides Base::Motion2DControllerSrv
        end

        
        begin
            #Next line raises if datatype is unkown
            Orocos.find_type_by_orocos_type_name("controldev/FourWheelCommand")
            Base::ControlLoop.declare 'FourWheel', 'controldev/FourWheelCommand'
            device_type 'Sliderbox' do
                provides Base::FourWheelControllerSrv
            end
            device_type 'CANSliderbox' do
                provides Base::FourWheelControllerSrv
            end
        rescue Orocos::TypekitTypeNotFound, Typelib::NotFound 
            Robot.warn "Could not declare FourWheel Controltype, the Datatype is unkown \
            did you build the Skid4Wheel deployment?"
        end


    end
end

class Controldev::Remote
    driver_for Dev::Controldev::CANJoystick, :as => 'joystick'

    if(Base.const_defined?("FourWheelControllerSrv"))
        driver_for Dev::Controldev::CANSliderbox, :as => 'sliderbox'
    end
end
    
if(Base.const_defined?("FourWheelControllerSrv"))
    class Controldev::SliderboxTask
        driver_for Dev::Controldev::Sliderbox, :as => 'sliderbox'
    end
end

class Controldev::JoystickTask
    driver_for Dev::Controldev::Joystick, :as => 'joystick'
end

