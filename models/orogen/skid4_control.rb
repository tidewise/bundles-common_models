class Skid4Control::SimpleController
    provides Srv::ActuatorController, :as => 'controller'
    provides Srv::Motion2DControlledSystem, :as => 'controlled_system'
end

class Skid4Control::FourWheelController
    provides Srv::ActuatorController, :as => 'controller'
    provides Srv::FourWheelControlledSystem, :as => 'controlled_system'
end

class Skid4Control::ConstantSpeedController
    provides Srv::ActuatorController, :as => 'controller'
    provides Srv::Motion2DControlledSystem, :as => 'controlled_system'
end
