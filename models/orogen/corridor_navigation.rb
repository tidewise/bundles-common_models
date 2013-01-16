require 'models/blueprints/sensors'
require 'models/blueprints/pose'
using_task_library 'trajectory_follower'

class CorridorNavigation::ServoingTask
    argument :initial_heading

    # Data writer connected to the heading port of the corridor servoing task
    attr_reader :direction_writer

    # Additional information for the transformer's automatic configuration
    transformer do
        associate_frame_to_ports 'laser', 'scan_samples'
        associate_frame_to_ports 'odometry', 'trajectory', 'gridDump', 'debugVfhTree'
        transform_input 'odometry_samples', 'body' => 'odometry'
    end

    on :start do |event|
        if initial_heading
            @direction_writer = servoing_child.heading_port.writer
            @direction_writer.write(initial_heading)
            Robot.info "corridor_servoing: initial heading=#{servoing_child.initial_heading * 180 / Math::PI}deg"
        end
    end
end

# Integration of the local servoing behaviour
#
# It adds the ability to initialize the map in the servoing by providing it in
# the initial_map argument
class CorridorNavigation::Servoing < Syskit::Composition
    # The initial map (if there is one). It must be a triplet [map, map_id,
    # map_pose] where
    #
    # map is the map as a marshalled envire environment
    # map_id the ID of the map in 'map'
    # map_pose is the current pose of the robot within this map
    argument :initial_map, :default => nil

    add Rock::Base::RelativePoseSrv, :as => 'pose'
    add Rock::Base::LaserRangeFinderSrv, :as => 'laser'
    add(Rock::Base::ControlLoop, :as => 'control').
        use(pose, 'controller' => TrajectoryFollower::Task)
    add_main_task(CorridorNavigation::ServoingTask, :as => 'servoing')
    pose_child.pose_samples_port.connect_to servoing_child.odometry_samples_port
    laser_child.connect_to servoing_child
    servoing_child.connect_to control_child

    # Event emitted if the initial_map argument is set to a non-nil value, once
    # the map is written to the corridor servoing
    event :initial_map_written

    on :start do
        if initial_map
            map, map_pose, map_id = *initial_map
            corridor_servoing_child.execute do
		if !servoing_child.setMap_op(map, map_id, map_pose)
		    raise "Failed to set initial map"
		end
                emit :initial_map_written
            end
        end
    end
end

# Extension of CorridorNavigation::Servoing to add the ability to always go
# towards a point in a reference frame
class CorridorNavigation::Explore < CorridorNavigation::Servoing
    # The target point
    # @return [Eigen::Vector3]
    argument :target
    # The threshold at which the target is considered as reached
    # @return [Numeric]
    argument :target_reached_threshold, :default => 1

    # This child provides the pose in which the target is expressed
    add Rock::Base::PoseSrv, :as => 'ref_pose'
    # TODO: be able to choose the same value for ref_pose and pose by default,
    # e.g.
    #
    #   use 'pose' => ref_pose_child
    overload('servoing', CorridorNavigation::ServoingTask).
        with_arguments(:initial_heading => nil)

    # Data reader connected to the pose port of the reference_pose child (i.e.
    # the reference pose in which the target point is expressed)
    attr_reader :ref_pose_reader
    # Data reader connected to the pose port of the pose child (i.e. the local
    # pose used by the corridor servoing)
    attr_reader :local_pose_reader

    # Event emitted when the target is reached
    event :target_reached
    forward :target_reached => :success

    on :start do |event|
        @ref_pose_reader = ref_pose_child.pose_samples_port.reader
        @local_pose_reader  = pose_child.pose_samples_port.reader
    end

    poll do
        return if !(ref = ref_pose_reader.read)
        return if !(local = local_pose_reader.read)

        direction = (target - ref.position)
        direction.z = 0
        if direction.norm < target_reached_threshold
            emit :target_reached
            return
        end

        # convert the reference heading to the heading in the frame used by
        # the servoing task
        ref_target_heading = Eigen::Vector3.UnitY.angle_to(direction)
        ref_cur_heading= Eigen::Vector3.UnitY.angle_to(ref.orientation * Eigen::Vector3.UnitY)
        local_cur_heading = Eigen::Vector3.UnitY.angle_to(local.orientation * Eigen::Vector3.UnitY)
        local_target_heading = ref_target_heading - (ref_cur_heading - local_cur_heading)

        if local_target_heading < 0
            local_target_heading += 2* Math::PI
        elsif local_target_heading > 2* Math::PI
            local_target_heading -= 2* Math::PI
        end
        direction_writer.write(local_target_heading)
    end
end

class CorridorNavigation::FollowingTask
    # Additional information for the transformer's automatic configuration
    transformer do
        transform_input "pose_samples", "body" => "world"
        associate_frame_to_ports "world", "trajectory"
    end
end

class CorridorNavigation::Following < Syskit::Composition
    add Rock::Base::PoseSrv, :as => 'pose'
    add(Rock::Base::ControlLoop, :as => 'control').
        use('pose' => pose_child, 'controller' => TrajectoryFollower::Task)
    add_main_task(CorridorNavigation::FollowingTask, :as => 'follower')
    connect follower_child => control_child
    connect pose_child => follower_child
end

