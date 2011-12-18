import_types_from 'base'
data_service_type 'Timestamper' do
    output_port 'timestamps', '/base/Time'
end
data_service_type 'TimestampInput' do
    input_port 'timestamps', '/base/Time'
end

