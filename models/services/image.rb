import_types_from 'base'

module Rock
    module Services
        data_service_type 'Image' do
            output_port 'frame', ro_ptr('/base/samples/frame/Frame')
        end
    end
end

