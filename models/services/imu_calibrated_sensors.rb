import_types_from 'base'

module Rock
    module Services
        data_service_type 'IMUCalibratedSensors' do
            output_port 'calibrated_sensors', '/base/samples/IMUSensors'
        end
    end
end
