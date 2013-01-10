require 'models/blueprints/pose'
import_types_from 'odometry'

module Rock
    module SLAM
        data_service_type 'Odometry' do
            provides RelativePoseSrv
            provides PoseDeltaSrv
        end

        # This data service provides contact point of the robot 
        # with its environment.
        data_service_type 'BodyContactState' do
            output_port 'contact_samples', '/odometry/BodyContactState'
        end

        class Odometry < Syskit::Composition
            add OrientationSrv, :as => 'imu'
            add OdometrySrv, :as => 'odometry'

            export odometry.pose_samples
            export odometry.pose_delta_samples
            provides OdometrySrv
        end
    end
end

