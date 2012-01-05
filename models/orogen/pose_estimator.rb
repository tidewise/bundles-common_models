class PoseEstimator::Task
    provides Srv::Pose

    orogen_spec.find_output_port('pose_samples').
        triggered_on('odometry_delta_samples')

    on :start do |event|
        if State.pose?
            yaw_bias = 0
            position_variance = Eigen::Vector3.new(0.09, 0.09, 0.09)
            yaw_variance  = (15 * Math::PI / 180) ** 2

            if State.pose.respond_to?(:cov_position)
                vx, vy, vz = State.pose.cov_position.data[0], State.pose.cov_position.data[4], State.pose.cov_position.data[8]
                position_variance = Eigen::Vector3.new(vx, vy, vz)
            end
            if State.pose.respond_to?(:yaw_bias)
                yaw_bias = State.pose.yaw_bias
            end
            if State.pose.respond_to?(:cov_orientation)
                yaw_variance = State.pose.cov_orientation.data[8]
            end
            orogen_task.set_position(State.pose.position, position_variance, yaw_bias, yaw_variance)
        end
    end
end

