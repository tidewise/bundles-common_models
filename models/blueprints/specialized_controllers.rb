load_system_model "blueprints/control"

# This declares an ActuatorController and ActuatorControlledSystem data service
# types, and the necessary specializations on Cmp::ControlLoop
Cmp::ControlLoop.declare "Actuator", 'base/actuators/Command',
    :feedback_type => 'base/actuators/Status'

# This declares an Motion2DController and Motion2DControlledSystem data service
# types, and the necessary specializations on Cmp::ControlLoop
Cmp::ControlLoop.declare "Motion2D", 'base/MotionCommand2D'

