import_types_from 'base'

module Rock
    module Services
        data_service_type 'IMURawSensors' do
            output_port 'raw_sensors', '/base/samples/IMUSensors'
        end
    end
end
