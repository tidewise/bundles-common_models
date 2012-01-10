class XsensImu::Task
    # Additional information to allow for the transformer's automatic
    # configuration
    transformer do
        associate_frame_to_ports "xsens", "calibrated_sensors"
        transform_output "orientation_samples", "xsens" => "world"
    end
    driver_for 'Dev::XsensImu' do
        provides Srv::Orientation
        provides Srv::CalibratedIMUSensors
    end
    provides Srv::TimestampInput, 'timestamps' => 'hard_timestamps'
end

