using_task_library 'trajectory_follower'

module TrajectoryFollower

    describe Task do
        it_should_be_configurable

        it "should pass non-nil trajectory argument to the task" do
            trajectory = [Types::Base::Trajectory.new(:spline => Types::Base::Geometry::Spline3.new)]
            stub_syskit_deployment_model(Task, "task")
            task = syskit_run_deployer(Task.with_arguments(:trajectory => trajectory))
            syskit_setup_component(task)
            task.start!
            process_events
            assert_equal trajectory, task.orocos_task.trajectory.read
        end
    end
end
