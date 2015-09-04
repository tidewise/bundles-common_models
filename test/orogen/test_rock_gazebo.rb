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

                model_with_frames = model.use_frames('test_source' => 'src_frame', 'test_target' => 'tgt_frame')
                task = syskit_stub_deploy_and_configure(model_with_frames)
                
                exports = task.orocos_task.exported_links
                assert_equal 1, exports.size

                export = exports.first
                assert_equal "src2tgt", export.port_name
                assert_equal "src_frame", export.source_frame
                assert_equal "tgt_frame", export.target_frame
                assert_equal "src_frame", export.source_link
                assert_equal "tgt_frame", export.target_link
            end
        end
    end
end
