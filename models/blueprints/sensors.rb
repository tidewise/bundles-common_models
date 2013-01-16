import_types_from 'base'
require 'models/blueprints/pose'

module Base
    data_service_type 'IMUSensorsSrv' do
        output_port 'sensors', '/base/samples/IMUSensors'
    end
    data_service_type 'CompensatedIMUSensorsSrv' do
        provides IMUSensorsSrv
    end
    data_service_type 'CalibratedIMUSensorsSrv' do
        provides IMUSensorsSrv
    end

    data_service_type 'ImageProviderSrv' do
        output_port 'frame', ro_ptr('/base/samples/frame/Frame')
    end

    data_service_type 'StereoPairProviderSrv' do
        output_port 'images', ro_ptr('/base/samples/frame/FramePair')
    end

    data_service_type 'DistanceImageProviderSrv' do
        output_port 'distance_images', 'base/samples/DistanceImage'
    end

    data_service_type 'LaserRangeFinderSrv' do
        output_port 'scans', '/base/samples/LaserScan'
    end
end

module Dev
    module Bus
    end

    module Sensors
        device_type 'GPS' do
            provides Base::PositionSrv
        end
        device_type 'LaserRangeFinder' do
            provides Base::LaserRangeFinderSrv
        end
    end
end

