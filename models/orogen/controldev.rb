require 'models/blueprints/control'

using_task_library 'canbus'

module Dev
    module Controldev

        Base::ControlLoop.declare 'RawCommand', 'controldev/RawCommand'
        Base::ControlLoop.declare 'FourWheel', 'controldev/FourWheelCommand'

        device_type 'Joystick' do
            #Rename it manually since otherwise the name is already used
            #but first we need to creare the new-named-ports
            output_port "motion_raw","/controldev/RawCommand"
            output_port "motion_2d","/base/MotionCommand2D" #Depricated

            provides Base::Motion2DControllerSrv, "command_out"=> "motion_2d" #Depricated
            provides Base::RawCommandControllerSrv, "command_out" => "motion_raw"
        end
        device_type 'CANJoystick' do
            output_port "motion_raw","/controldev/RawCommand"
            output_port "motion_2d","/base/MotionCommand2D" #Depricated

            provides Base::Motion2DControllerSrv, "command_out"=> "motion_2d" #Depricated
            provides Base::RawCommandControllerSrv, "command_out" => "motion_raw"
            
            provides Dev::Bus::CAN::ClientInSrv
        end


        device_type 'Sliderbox' do
            provides Base::FourWheelControllerSrv
        end

        device_type 'CANSliderbox' do
            provides Base::FourWheelControllerSrv
        end
        
        device_type 'Mouse3D' do
            provides Base::RawCommandControllerSrv
        end
    end
end

class Controldev::Mouse3DTask
    driver_for Dev::Controldev::Mouse3D, :as => 'mouse3d'
end

class Controldev::Remote
    driver_for Dev::Controldev::CANJoystick, "from_bus" => "canJoystick", :as => 'joystick'
    #Results in an problem that there must be an device too for the sliderbox.
    #NEverless the RawCommand should be the only used datatype.
    #The Other one's are Depricated and will be removed in the future.
#    driver_for Dev::Controldev::CANSliderbox, :as => 'sliderbox'
end

class Controldev::SliderboxTask
    driver_for Dev::Controldev::Sliderbox, :as => 'sliderbox'
end

class Controldev::JoystickTask
    driver_for Dev::Controldev::Joystick, :as => 'joystick'
end

