require 'models/blueprints/control'

class Skid4Control::SimpleController
    provides Base::ActuatorControllerSrv, :as => 'controller'
    provides Base::Motion2DControlledSystemSrv, :as => 'controlled_system'
end

using_task_library 'controldev'
class Skid4Control::FourWheelController
    provides Base::ActuatorControllerSrv, :as => 'controller'
    provides Base::FourWheelControlledSystemSrv, :as => 'controlled_system'
end

class Skid4Control::ConstantSpeedController
    provides Base::ActuatorControllerSrv, :as => 'controller'
    provides Base::Motion2DControlledSystemSrv, :as => 'controlled_system'
end
