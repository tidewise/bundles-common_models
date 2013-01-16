require 'models/blueprints/pose'
import_types_from 'odometry'

module Rock
    module SLAM
        data_service_type 'OdometrySrv' do
            provides Rock::Base::RelativePoseSrv
            provides Rock::Base::PoseDeltaSrv
        end

        # This data service provides contact point of the robot 
        # with its environment.
        data_service_type 'BodyContactStateSrv' do
            output_port 'contact_samples', '/odometry/BodyContactState'
        end

        class Odometry < Syskit::Composition
            add Rock::Base::OrientationSrv, :as => 'orientation'
            add OdometrySrv, :as => 'odometry'
            export odometry_child.pose_samples_port
            export odometry_child.pose_delta_samples_port
            provides OdometrySrv, :as => 'odometry'
        end
    end
end

