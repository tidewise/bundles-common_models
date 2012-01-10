load_system_model 'blueprints/control'

# Integration of the trajectory follower component
#
# It can be used in a ControlLoop composition as a Motion2DCommand provider.
# In this case, the corresponding specialization is used, which requires a
# Srv::Pose provider.
#
# It can also be used with a static trajectory. One can set the following two
# configuration parameters:
#
#   Conf.trajectory_file = path_to_trajectory_file
#
# where the trajectory file contains a trajectory (i.e.
# std::vector<wrappers::Waypoint> marshalled by typelib. It can be generated by
# getting a data sample and doing
#
#   File.open('file_name', 'w') do |io|
#     io.write(trajectory_sample.to_byte_array)
#   end
#
# Moreover, if the Conf.reverse_trajectory flag is set, the trajectory follower
# will follow the static trajectory in the reverse direction
class TrajectoryFollower::Task
    provides Srv::Motion2DController

    argument :trajectory, :default => nil

    # Add some more information for the transformer integration
    transformer do
        associate_frame_to_ports "world", "trajectory"
        transform_input "pose", "body" => "world"
    end

    on :start do |event|
        if trajectory
            @trajectory_writer = data_writer 'trajectory'
            @trajectory_writer.write(trajectory)
        end
    end
end

Cmp::ControlLoop.specialize 'controller' => TrajectoryFollower::Task, 'controlled_system' => Srv::Motion2DControlledSystem do
    add Srv::Pose, :as => 'pose'
    export controller.trajectory
    autoconnect
end

