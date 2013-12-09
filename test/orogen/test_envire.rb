using_task_library 'envire'
require 'fakefs/safe'

module Envire
    describe SynchronizationTransmitter do
        before do
            FakeFS.activate!
        end
        after do
            FakeFS.deactivate!
            FakeFS::FileSystem.clear
        end

        it "should fail to configure if the provided initial map does not exist" do
            stub_syskit_deployment_model(Envire::SynchronizationTransmitter, 'task')
            envire = syskit_run_deployer(Envire::SynchronizationTransmitter.with_arguments(:initial_map => 'bogus_path'))
            assert_raises(ArgumentError) do
                syskit_start_component(envire)
            end
        end

        it "should load the provided environment on the task" do
            FileUtils.mkdir_p "/environment"
            stub_syskit_deployment_model(Envire::SynchronizationTransmitter, 'task')
            envire = syskit_run_deployer(Envire::SynchronizationTransmitter.with_arguments(:initial_map => '/environment'))
            flexmock(envire).should_receive_operation(:loadEnvironment).once.
                with('/environment')
            syskit_start_component(envire)
        end
    end

    describe SynchronizationReceiver do
        it_should_be_configurable
    end
end
