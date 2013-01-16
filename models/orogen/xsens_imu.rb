Dev::Sensors.device_type 'XsensAHRS' do
    provides Rock::Base::OrientationSrv
    provides Rock::Base::CalibratedIMUSensorsSrv
end

class XsensImu::Task
    # Additional information to allow for the transformer's automatic
    # configuration
    transformer do
        associate_frame_to_ports "xsens", "calibrated_sensors"
        transform_output "orientation_samples", "xsens" => "world"
    end
    
    driver_for Dev::Sensors::XsensAHRS, :as => 'driver'
    provides Rock::Base::TimestampInputSrv, 'timestamps' => 'hard_timestamps', :as => 'timestamps'
end

