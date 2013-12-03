import_types_from 'base'

module Base
    data_service_type 'ForceSrv' do
        output_port 'force_samples', 'base/samples/Wrench'
    end
    
    data_service_type 'TorqueSrv' do
        output_port 'torque_samples', 'base/samples/Wrench'
    end
    
    # Provider of a full wrench
    data_service_type 'WrenchSrv' do
        output_port 'wrench_samples', 'base/samples/Wrench'
        provides ForceSrv
        provides TorqueSrv
    end
end

