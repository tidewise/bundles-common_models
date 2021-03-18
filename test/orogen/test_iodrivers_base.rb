# frozen_string_literal: true

using_task_library "iodrivers_base"

module OroGen
    describe iodrivers_base.Task do
        it { is_configurable }
    end

    describe iodrivers_base.Proxy do
        run_simulated do
            it { is_configurable }
        end
        run_live do
            it "fails to configure if called without a URI" do
                assert_raises(Orocos::StateTransitionFailed) do
                    syskit_deploy_and_configure
                end
            end
        end
    end
end
