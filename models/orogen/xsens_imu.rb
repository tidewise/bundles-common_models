require 'models/blueprints/timestamping'

Dev::Sensors.device_type 'XsensAHRS' do
    provides Base::OrientationSrv
    provides Base::CalibratedIMUSensorsSrv
end

class XsensImu::Task
    # Additional information to allow for the transformer's automatic
    # configuration
    transformer do
        associate_frame_to_ports "imu", "calibrated_sensors"
        transform_output "orientation_samples", "imu" => "world"
    end
    
    driver_for Dev::Sensors::XsensAHRS, :as => 'driver'
    provides Base::TimestampInputSrv, 'timestamps' => 'hard_timestamps', :as => 'timestamps'
end

