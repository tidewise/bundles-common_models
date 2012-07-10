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
end

composition 'CorridorServoing' do
    add Srv::Pose, :as => 'mapper'

    add Srv::LaserRangeFinder, :as => 'laser'
    add Srv::RelativePose, :as => 'pose'
    add(Compositions::ControlLoop, :as => 'control').
        use(pose, 'controller' => TrajectoryFollower::Task)
    add_main_task(CorridorNavigation::ServoingTask, :as => 'servoing')
    connect pose.pose_samples => servoing.odometry_samples
    connect laser => servoing
    connect servoing => control

    
    on :start do |event|
        @direction_writer = servoing_child.data_writer 'heading'
	@pose_reader = pose_child.data_reader 'pose_samples'
        if servoing_child.initial_heading
            @direction_writer.write(servoing_child.initial_heading)
            Robot.info "corridor_servoing: initial heading=#{servoing_child.initial_heading * 180 / Math::PI}deg"
        end
    end

    poll do
	target_point = nil
	if(parent_task && parent_task.corridor && State.pose.position?)
	    median_curve = parent_task.corridor.median_curve
	    curve_pos = median_curve.find_one_closest_point(State.pose.position, median_curve.start_param, 0.01)
	    geom_res = (median_curve.end_param - median_curve.start_param) / median_curve.curve_length
	    #4 meter lock ahead
	    curve_pos = [curve_pos + geom_res * 4.0, median_curve.end_param].min
	    target_point = median_curve.get(curve_pos)
	else
	    target_point = servoing_child.target_point
	end

        if target_point && State.pose.position?
            direction = (target_point - State.pose.position)
            heading = Eigen::Vector3.UnitY.angle_to(direction)
	    
	    #convert global heading to odometry heading
            heading_world = Eigen::Vector3.UnitY.angle_to(State.pose.orientation * Eigen::Vector3.UnitY)
	    odo_sample = @pose_reader.read
	    if(odo_sample)
		
		if((State.pose.time - odo_sample.time).to_f.abs > 0.4)
		    puts("Warning, global and odometry times are diverged ")
		end
		
		heading_odometry = Eigen::Vector3.UnitY.angle_to(odo_sample.orientation * Eigen::Vector3.UnitY)

		final_heading = heading - (heading_world - heading_odometry)
	    
		if(final_heading < 0)
		    final_heading += 2* Math::PI
		end

		if(final_heading > 2* Math::PI)
		    final_heading -= 2* Math::PI
		end

		@direction_writer.write(final_heading)
		
		#ignore z
		direction.z = 0
		#we are finished if we are within 20 cm to the goal
		if(direction.norm() < 0.2)
		    puts("CS :Goal reached \n")
		    @direction_writer.disconnect()
		    emit :target_reached
		end
	    end
        end
    end
    event :target_reached
    
end

composition 'CorridorFollowing' do
    add Srv::Pose, :as => 'pose'
    add(Compositions::ControlLoop, :as => 'control').
        use(pose, 'controller' => TrajectoryFollower::Task)
    add_main_task(CorridorNavigation::FollowingTask, :as => 'follower')
    connect follower.trajectory => control.trajectory
    autoconnect
end

