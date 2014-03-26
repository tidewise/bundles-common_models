require 'models/blueprints/control'

using_task_library 'canbus'

module Dev
    module Controldev

        Base::ControlLoop.declare 'RawCommand', 'controldev/RawCommand'
#        Base::ControlLoop.declare 'Motion2D', '/base/MotionCommand2D'

        device_type 'Joystick' do
            provides Base::Motion2DControllerSrv
        end 

        device_type 'Raw' do 
            provides Base::RawCommandControllerSrv
        end

        device_type 'Mouse3D' do
            provides Base::RawCommandControllerSrv
        end
    end
end

class Controldev::JoystickTask
    driver_for Dev::Controldev::Raw, :as => 'raw'
    driver_for Dev::Controldev::Joystick, :as => 'motion_2d'
end

class Controldev::Mouse3DTask
    driver_for Dev::Controldev::Mouse3D, :as => 'mouse3d'
end

class Controldev::Remote
    provides Dev::Bus::CAN::ClientInSrv, "from_bus" => "canInputDevice" ,:as => "can"

    driver_for Dev::Controldev::Raw, :as => 'joystick'
end

