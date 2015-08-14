using_task_library 'canbus'

module OroGen
    module Canbus
        describe Task do
            it "fails on configure if a device has no can ID" do
                dev = syskit_stub_device(Rock::Devices::Bus::CAN)
                dev_task = syskit_deploy(dev)
                bus_task = dev_task.children.first
                assert_raises(ArgumentError) do
                    syskit_setup(bus_task)
                end
            end
            it "calls the watch operation for each attached device" do
                dev = syskit_stub_device(Rock::Devices::Bus::CAN)
                dev.can_id(0x01, 0x11)
                dev_task = syskit_deploy(dev)
                bus_task = dev_task.children.first
                flexmock(bus_task).should_receive_operation(:watch).once.
                    with('dev', 0x01, 0x11)
                syskit_setup(bus_task)
            end
        end

        describe InterfaceTask do
        end
    end
end

