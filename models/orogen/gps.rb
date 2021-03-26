# frozen_string_literal: true

require "common_models/models/devices/gps/mb500"
require "common_models/models/devices/gps/generic"

OroGen.extend_model OroGen.gps.BaseTask do
    def configure
        super

        if Conf.utm_local_origin?
            orocos_task.origin = Conf.utm_local_origin
        end
    end
end

OroGen.extend_model OroGen.gps.MB500Task do
    driver_for CommonModels::Devices::GPS::MB500, as: "driver"
end

OroGen.extend_model OroGen.gps.GPSDTask do
    driver_for CommonModels::Devices::GPS::Generic, as: "driver"
end
