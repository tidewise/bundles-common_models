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

class CorridorNavigation::ServoingTask
    argument :initial_heading

    # Additional information for the transformer's automatic configuration
    transformer do
        associate_frame_to_ports 'laser', 'scan_samples'
        associate_frame_to_ports 'odometry', 'trajectory'
        transform_input 'odometry_samples', 'body' => 'odometry'
    end

    on :start do |event|
        if initial_heading
            direction_writer = data_writer 'heading'
            direction_writer.write(@initial_heading || self.initial_heading)
            Robot.info "corridor_servoing: initial heading=#{initial_heading * 180 / Math::PI}deg"
        end
    end
end

composition 'CorridorServoing' do
    add Srv::LaserRangeFinder
    add Srv::RelativePose, :as => 'pose'
    add(Compositions::ControlLoop, :as => 'control').
        use(pose, 'controller' => TrajectoryFollower::Task)
    add_main_task(CorridorNavigation::ServoingTask, :as => 'servoing')
    connect pose.pose_samples => servoing.odometry_samples
    autoconnect
end

composition 'CorridorFollowing' do
    add Srv::Pose, :as => 'pose'
    add(Compositions::ControlLoop, :as => 'control').
        use(pose, 'controller' => TrajectoryFollower::Task)
    add_main_task(CorridorNavigation::FollowingTask, :as => 'follower')
    connect follower.trajectory => control.trajectory
    autoconnect
end

