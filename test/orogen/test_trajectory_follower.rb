using_task_library 'trajectory_follower'

module OroGen
    module TrajectoryFollower
        describe Task do
            it "should be configurable" do
                syskit_stub_deploy_and_configure(Task.use_frames('world' => 'world'))
            end

            it "should pass non-nil trajectory argument to the task" do
                trajectory = [Types.base.Trajectory.new(spline: SISL::Spline3.new)]
                task = syskit_stub_deploy_configure_and_start(Task.use_frames('world' => 'world').with_arguments(trajectory: trajectory))
                assert_equal trajectory, task.orocos_task.trajectory.read
            end
        end
    end
end
