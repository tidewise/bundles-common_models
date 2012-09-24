
composition 'Odometry' do
    add Srv::Orientation, :as => 'imu'
    add Srv::Odometry, :as => 'odometry'

    export odometry.pose_samples
    export odometry.pose_delta_samples
    provides Srv::Odometry
end




