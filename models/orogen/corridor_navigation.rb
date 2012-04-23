load_system_model 'blueprints/sensors'
load_system_model 'blueprints/pose'
using_task_library 'trajectory_follower'

class CorridorNavigation::FollowingTask
    # Additional information for the transformer's automatic configuration
    transformer do
        transform_input "pose_samples", "body" => "world"
        associate_frame_to_ports "world", "trajectory"
    end
end

# The task representing the corridor servoing computation
#
# It can be used in two modes:
#
# * if an initial heading is set (and target point is set to nil), the servoing
#   will follow that heading
# * if a target point is given (and initial_heading is set to nil), the servoing
#   will try to reach that position by continuously trying to get towards that
#   point. It uses State.pose.position for its current position.
class CorridorNavigation::ServoingTask
    argument :initial_heading
    argument :target_point

    # Additional information for the transformer's automatic configuration
    transformer do
        associate_frame_to_ports 'laser', 'scan_samples'
        associate_frame_to_ports 'odometry', 'trajectory', 'gridDump', 'debugVfhTree'
        transform_input 'odometry_samples', 'body' => 'odometry'
    end

    on :start do |event|
        @direction_writer = data_writer 'heading'
        if initial_heading
            @direction_writer.write(self.initial_heading)
            Robot.info "corridor_servoing: initial heading=#{initial_heading * 180 / Math::PI}deg"
        end
    end

    poll do
        if target_point && State.pose.position?
            direction = (target_point - State.pose.position)
            heading = Eigen::Vector3.UnitY.angle_to(direction) 
            @direction_writer.write(heading)
        end
    end
end

composition 'CorridorServoing' do
    add Srv::LaserRangeFinder, :as => 'laser'
    add Srv::RelativePose, :as => 'pose'
    add(Compositions::ControlLoop, :as => 'control').
        use(pose, 'controller' => TrajectoryFollower::Task)
    add_main_task(CorridorNavigation::ServoingTask, :as => 'servoing')
    connect pose.pose_samples => servoing.odometry_samples
    connect laser => servoing
    connect servoing => control
end

composition 'CorridorFollowing' do
    add Srv::Pose, :as => 'pose'
    add(Compositions::ControlLoop, :as => 'control').
        use(pose, 'controller' => TrajectoryFollower::Task)
    add_main_task(CorridorNavigation::FollowingTask, :as => 'follower')
    connect follower.trajectory => control.trajectory
    autoconnect
end

