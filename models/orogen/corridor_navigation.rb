load_system_model 'blueprints/sensors'
load_system_model 'blueprints/pose'
using_task_library 'trajectory_follower'

class CorridorNavigation::ServoingTask
    argument :initial_heading

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

