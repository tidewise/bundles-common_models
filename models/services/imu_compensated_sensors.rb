import_types_from 'base'

module Rock
    module Services
        data_service_type 'IMUCompensatedSensors' do
            output_port 'compensated_sensors', '/base/samples/IMUSensors'
        end
    end
end
