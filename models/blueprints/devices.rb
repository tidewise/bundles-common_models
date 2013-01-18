require 'models/blueprints/sensors'

# The module under which all device models are defined
module Dev
    # The module under which all communication busses are defined
    module Bus
    end

    # The module under which all sensors are defined
    module Sensors
        device_type 'GPS' do
            provides Base::PositionSrv
        end
        device_type 'LaserRangeFinder' do
            provides Base::LaserRangeFinderSrv
        end
    end

    # The module under which platforms are declared. Platforms are e.g. mobile
    # platforms, vehicles, ...
    module Platforms
    end

    # Simulated platforms and sensors
    module Simulation
    end
end

