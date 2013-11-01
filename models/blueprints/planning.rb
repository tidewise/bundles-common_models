import_types_from 'base'

module Rock
    module Planning
        data_service_type 'TrajectoryExecutionSrv' do
            input_port 'trajectory', 'std::vector</base/Trajectory'
        end
    end
end
