using_task_library 'canbus'

module Canbus
    describe Dev::Bus::CAN do
        it "allows to specify the can ID on the attached devices" do
            dev = syskit_stub_attached_device(Dev::Bus::CAN)
            dev.can_id(0x01, 0x11)
            assert_equal [0x01, 0x11], dev.can_id
        end

        it "raises ArgumentError if the can ID and mask do not make sense" do
            dev = syskit_stub_attached_device(Dev::Bus::CAN)
            assert_raises(ArgumentError) do
                dev.can_id(0x0f, 0x0e)
            end
        end
    end

    describe Task do
        it "fails on configure if a device has no can ID" do
            dev = syskit_stub_attached_device(Dev::Bus::CAN, 'dev')
            dev_task = syskit_run_deployer(dev)
            bus_task = dev_task.children.first
            assert_raises(ArgumentError) do
                syskit_setup_component(bus_task)
            end
        end
        it "calls the watch operation for each attached device" do
            dev = syskit_stub_attached_device(Dev::Bus::CAN, 'dev')
            dev.can_id(0x01, 0x11)
            dev_task = syskit_run_deployer(dev)
            bus_task = dev_task.children.first
            flexmock(bus_task).should_receive_operation(:watch).once.
                with('dev', 0x01, 0x11)
            syskit_setup_component(bus_task)
        end
    end

    describe InterfaceTask do
    end
end
