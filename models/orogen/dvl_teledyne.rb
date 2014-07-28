require 'models/blueprints/timestamping'
require 'models/blueprints/devices'

module Dev
    module Sensors
        device_type 'DVL' do
            provides Base::GroundDistanceSrv
            provides Base::VelocitySrv
        end
    end
end



class DvlTeledyne::Task
    driver_for Dev::Sensors::DVL, :as => 'driver', "distance" => "ground_distance", "velocity_samples" => "velocity_samples"
end

