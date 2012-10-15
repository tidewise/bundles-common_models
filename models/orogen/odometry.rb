
class Odometry::Skid4OdometryTask
    # Additional information for the transformer's automatic configuration
    transformer do
        associate_frame_to_ports "body", "odometry_delta_samples"
        transform_output "odometry_samples", "body" => "odometry"
       # transform_input "orientation_samples", "imu" => "world"
    end
    
    provides Srv::Odometry, 'pose_samples' => 'odometry_samples', 'pose_delta_samples' => 'odometry_delta_samples'
#    provides Srv::Odometry, 'odometry_samples' => 'pose_samples', 'odometry_delta_samples' => 'pose_delta_samples' 
end

class Odometry::ContactPointTask
    # Additional information for the transformer's automatic configuration
    transformer do
        associate_frame_to_ports "body", "odometry_delta_samples"
        transform_output "odometry_samples", "body" => "odometry"
       # transform_input "orientation_samples", "imu" => "world"
    end
    
#    provides Srv::Odometry, 'odometry_samples' => 'pose_samples', 'odometry_delta_samples' => 'pose_delta_samples' 
    provides Srv::Odometry, 'pose_samples' => 'odometry_samples', 'pose_delta_samples' => 'odometry_delta_samples'
end


Cmp::Odometry.specialize 'odometry' => Odometry::ContactPointTask do
    add Srv::BodyContactState, :as => 'bcp_provider'
    
    connect bcp_provider => odometry
end
