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
    add Srv::Pose, :as => 'localizer'

    add Srv::LaserRangeFinder, :as => 'laser'
    add Srv::RelativePose, :as => 'pose'
    add(Compositions::ControlLoop, :as => 'control').
        use(pose, 'controller' => TrajectoryFollower::Task)
    add_main_task(CorridorNavigation::ServoingTask, :as => 'servoing')
    connect pose.pose_samples => servoing.odometry_samples
    connect laser => servoing
    connect servoing => control

    
    on :start do |event|
	Robot.info("Starting Corridor Servoing")

	@direction_writer = servoing_child.data_writer 'heading'
	@odometry_pose_reader = pose_child.data_reader 'pose_samples'
	@localizer_pose_reader = localizer_child.data_reader 'pose_samples'
        if servoing_child.initial_heading
            @direction_writer.write(servoing_child.initial_heading)
            Robot.info "corridor_servoing: initial heading=#{servoing_child.initial_heading * 180 / Math::PI}deg"
        end

	@corridor = nil
	if(parent_task)
	    @corridor = parent_task.corridor
	end

	# Make sure that the corridor servoing is not started before we wrote
        # the current map
        child_from_role('servoing').should_start_after inital_map_written_event

	#finish if the target is reached
	target_reached_event.forward_to success_event

	servoing_child.exception_event.forward_to servoing_error_event

	script do
	    #make shure corridor servoing is stopped
	    #the set map operation will fail if CS is not stopped
	    poll do
		state = servoing_child.read_current_state()
		if(state == :STOPPED)
		    transition!
		end
	    end

	    
	    #be shure control and servoing are running
	    wait_any(control_child.start_event)
	    wait_any(control_child.controller_child.start_event)
	    wait_any(mapper_child.start_event)
	    wait_any(mapper_child.eslam_child.start_event)

	    execute do
		map_reader = data_reader('mapper', 'map')
		map_pose = mapper_child.eslam_child.orogen_task.cloneMap()
		map_id = mapper_child.eslam_child.orogen_task.map_id

		map = map_reader.read()
		if(!map)
		    raise("CS Error, did not get map after request")
		end
		   
		if(!servoing_child.orogen_task.setMap(map, map_id, map_pose))
		    raise("Failed to set map")
		end
	    end	
	    execute do
		emit :inital_map_written
	    end
	end
    end

    event :inital_map_written
    
    event :servoing_error
    # Needed to make the composition fail when the task fails
    forward :servoing_error => :failed

    
    poll do
	target_point = nil
	cur_pose = @localizer_pose_reader.read
	if(@corridor && cur_pose)
	    median_curve = @corridor.median_curve
	    curve_pos = median_curve.find_one_closest_point(cur_pose.position, median_curve.start_param, 0.01)
	    geom_res = (median_curve.end_param - median_curve.start_param) / median_curve.curve_length
	    #4 meter lock ahead
	    curve_pos = [curve_pos + geom_res * 1.2, median_curve.end_param].min
	    target_point = median_curve.get(curve_pos)
	else
	    target_point = servoing_child.target_point
	end

        if target_point && cur_pose
            direction = (target_point - cur_pose.position)
            heading = Eigen::Vector3.UnitY.angle_to(direction)
	    
	    #convert global heading to odometry heading
            heading_world = Eigen::Vector3.UnitY.angle_to(cur_pose.orientation * Eigen::Vector3.UnitY)
	    odo_sample = @odometry_pose_reader.read
	    if(odo_sample)
		
		if((cur_pose.time - odo_sample.time).to_f.abs > 0.4)
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
                    puts("CS: reached target position #{target_point}")
		    #this is a hack that makes the robot stop instantanious
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

