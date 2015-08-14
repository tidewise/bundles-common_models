require 'rock/models/services/raw_io'
class OroGen::IodriversBase::Task
    provides Rock::Services::RawIO, as: 'raw_io',
        'raw_out' => 'io_raw_out',
        'raw_in' => 'io_raw_in'
end

