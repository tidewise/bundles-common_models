using_task_library 'rock_gazebo'

module OroGen
    module RockGazebo
        describe WorldTask do
            run_simulated

            it { is_configurable }
        end

        describe ModelTask do
            run_simulated

            it { is_configurable }

            it "sets up the link export based on the instanciated link_export services" do
                model = ModelTask.specialize
                model.require_dynamic_service 'link_export', as: "test",
                    port_name: 'src2tgt'
                robot_model = Syskit::Robot::RobotDefinition.new
                test_link_dev = robot_model.device Rock::Devices::Gazebo::Link, as: 'test'
                test_link_dev.period(0.5)

                model_with_frames = model.
                    use_frames('test_source' => 'src_frame', 'test_target' => 'tgt_frame').
                    with_arguments('test_dev' => test_link_dev).
                    transformer { frames 'src_frame', 'tgt_frame' }
                task = syskit_stub_deploy_and_configure(model_with_frames)
                
                exports = task.orocos_task.exported_links
                assert_equal 1, exports.size

                export = exports.first
                assert_equal "src2tgt", export.port_name
                assert_equal "src_frame", export.source_frame
                assert_equal "tgt_frame", export.target_frame
                assert_equal "src_frame", export.source_link
                assert_equal "tgt_frame", export.target_link
                assert_equal 0.5, export.port_period.to_f
            end

            it "uses a default period of zero" do
                model = ModelTask.specialize
                model.require_dynamic_service 'link_export', as: "test",
                    port_name: 'src2tgt'
                robot_model = Syskit::Robot::RobotDefinition.new
                test_link_dev = robot_model.device Rock::Devices::Gazebo::Link, as: 'test'

                model_with_frames = model.
                    use_frames('test_source' => 'src_frame', 'test_target' => 'tgt_frame').
                    with_arguments('test_dev' => test_link_dev).
                    transformer { frames 'src_frame', 'tgt_frame' }
                task = syskit_stub_deploy_and_configure(model_with_frames)
                
                exports = task.orocos_task.exported_links
                assert_equal Time.at(0), exports.first.port_period
            end
        end
    end
end
