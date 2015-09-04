import_types_from 'base'

module Rock
    module Services
        data_service_type 'SonarBeam' do
            output_port 'samples', '/base/samples/SonarBeam'
        end
    end
end
