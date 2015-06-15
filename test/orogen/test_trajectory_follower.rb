using_task_library 'trajectory_follower'

module OroGen
    module TrajectoryFollower
        describe Task do
            it_should_be_configurable

            it "should pass non-nil trajectory argument to the task" do
                trajectory = [Types.base.Trajectory.new(spline: SISL::Spline3.new)]
                task = stub_deploy_and_start(Task.with_arguments(trajectory: trajectory))
                assert_equal trajectory, task.orocos_task.trajectory.read
            end
        end
    end
end
