import_types_from 'base'

data_service_type 'IMUSensors' do
    output_port 'sensors', '/base/samples/IMUSensors'
end
data_service_type 'CompensatedIMUSensors' do
    provides Srv::IMUSensors
end
data_service_type 'CalibratedIMUSensors' do
    provides Srv::IMUSensors
end

data_service_type 'ImageProvider' do
    output_port 'images', ro_ptr('/base/samples/frame/Frame')
end

data_service_type 'StereoPairProvider' do
    output_port 'images', ro_ptr('/base/samples/frame/FramePair')
end

data_service_type 'LaserRangeFinder' do
    output_port 'scans', '/base/samples/LaserScan'
end


