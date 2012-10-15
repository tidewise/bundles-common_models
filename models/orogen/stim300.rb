class Stim300::Task
    # Additional information to allow for the transformer's automatic
    # configuration
    transformer do
        associate_frame_to_ports "stim300", "calibrated_sensors"
	associate_frame_to_ports "stim300", "incremental_velocity"
    end
    
    driver_for 'Dev::Stim300' do
        provides Srv::CalibratedIMUSensors
    end
end

