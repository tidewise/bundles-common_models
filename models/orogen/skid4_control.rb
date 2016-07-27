require 'models/blueprints/control'

class Skid4Control::SimpleController
    provides Base::JointsControllerSrv, :as => 'controller'
    provides Base::Motion2DControlledSystemSrv, :as => 'controlled_system'
end
