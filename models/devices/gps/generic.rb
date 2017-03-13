require 'models/services/position'

module Rock
    module Devices
        module GPS
            device_type 'Generic' do
                provides Services::Position
            end
        end
    end
end
