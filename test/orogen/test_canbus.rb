using_task_library 'canbus'

module OroGen
    module Canbus
        describe Task do
            run_simulated do
                it "fails on configure if a device has no can ID" do
                    dev = syskit_stub_attached_device(CommonModels::Devices::Bus::CAN)
                    dev.period(0.1)
                    dev_task = syskit_deploy(dev)
                    bus_task = dev_task.children.first
                    assert_raises(ArgumentError) do
                        syskit_configure(bus_task)
                    end
                end
                it "calls the watch operation for each attached device" do
                    dev = syskit_stub_attached_device(CommonModels::Devices::Bus::CAN, as: 'dev')
                    dev.period(0.1)
                    dev.can_id(0x01, 0x11)
                    dev_task = syskit_deploy(dev)
                    bus_task = dev_task.children.first
                    syskit_start_execution_agents(bus_task)
                    syskit_configure(bus_task)
                    assert_equal [['dev', 0x1, 0x11]], bus_task.orocos_task.stub_configured_watches
                end
            end
        end

        describe InterfaceTask do
        end
    end
end

