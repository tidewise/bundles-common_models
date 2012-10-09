load_system_model 'blueprints/pose'
import_types_from 'odometry'

data_service_type 'Odometry' do
    provides Srv::RelativePose
    provides Srv::PoseDelta
end

# This data service provides contact point of the robot 
# with its environment.
data_service_type 'BodyContactState' do
    output_port 'contact_samples', '/odometry/BodyContactState'
end


composition 'Odometry' do
    add Srv::Orientation, :as => 'imu'
    add Srv::Odometry, :as => 'odometry'

    export odometry.pose_samples
    export odometry.pose_delta_samples
    provides Srv::Odometry
end




