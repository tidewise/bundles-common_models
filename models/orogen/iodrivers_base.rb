# frozen_string_literal: true

require "common_models/models/devices/bus/raw_io"
require "common_models/models/services/raw_io"

Syskit.extend_model OroGen.iodrivers_base.Task do
    provides CommonModels::Devices::Bus::RawIO::ClientSrv,
             { "to_bus" => "io_raw_out", "from_bus" => "io_raw_in" },
             as: "raw_io_bus"

    provides CommonModels::Services::RawIO,
             { "raw_out" => "io_raw_out", "raw_in" => "io_raw_in" },
             as: "raw_io"
end
