import_types_from 'base'

data_service_type 'Position' do
    output_port 'position_samples', '/base/samples/RigidBodyState'
end

data_service_type 'Orientation' do
    output_port 'orientation_samples', '/base/samples/RigidBodyState'
end

data_service_type 'Pose' do
    output_port 'pose_samples', '/base/samples/RigidBodyState'
    provides Srv::Position,    'position_samples' => 'pose_samples'
    provides Srv::Orientation, 'orientation_samples' => 'pose_samples'
end

data_service_type 'Transformation' do
    provides Srv::Pose
end

# This data service can be used to represent estimators that provide a pose that
# is a best estimate of the global pose of the system. Because it is a best
# estimate, it can actually jump
#
# It is typically a pose estimator which fuses a global position measurement
# such as GPS
data_service_type 'GlobalPose' do
    provides Srv::Pose
end

# This data service can be used to represent pose estimators that provide a pose
# which is locally consistent, but that will stray away from the true global
# pose in the long run. These estimators should not jump, as it would break the
# local consistency constraint
#
# It is typically an odometry
data_service_type 'RelativePose' do
    provides Srv::Pose
end

# This data service provides deltas in pose (i.e. pose change between two time
# steps). Usually, a component that provides a PoseDelta will also provide
# RelativePose.
data_service_type 'PoseDelta' do
    output_port 'pose_delta_samples', '/base/samples/RigidBodyState'
end

data_service_type 'Odometry' do
    provides Srv::RelativePose
    provides Srv::PoseDelta
end

# This data service provides contact point of the robot 
# with its environment.
data_service_type 'BodyContactState' do
    output_port 'contact_samples', '/odometry/BodyContactState'
end

