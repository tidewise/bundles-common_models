require 'models/blueprints/control'

class Skid4Control::SimpleController
    provides Rock::Base::ActuatorControllerSrv, :as => 'controller'
    provides Rock::Base::MotionSrv2DControlledSystem, :as => 'controlled_system'
end

using_task_library 'controldev'
class Skid4Control::FourWheelController
    provides Rock::Base::ActuatorControllerSrv, :as => 'controller'
    provides Rock::Base::FourWheelControlledSystemSrv, :as => 'controlled_system'
end

class Skid4Control::ConstantSpeedController
    provides Rock::Base::ActuatorControllerSrv, :as => 'controller'
    provides Rock::Base::MotionSrv2DControlledSystem, :as => 'controlled_system'
end
