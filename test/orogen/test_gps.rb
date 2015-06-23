using_task_library 'gps'

module Gps
    describe BaseTask do
    end

    describe GPSDTask do
        it_should_be_configurable

        it "should set the UTM local origin on the task if it is set on Conf" do
            origin = Conf.utm_local_origin = Eigen::Vector3.new(1, 2, 3)
            driver_m = syskit_stub_driver_model(Dev::Sensors::GPS, :using => GPSDTask, :as => 'dev')
            task = syskit_run_deployer(driver_m)
            syskit_setup_component(task)
            assert_equal origin, task.orocos_task.origin
        end
    end

    describe MB500Task do
        it_should_be_configurable

        it "should set the UTM local origin on the task if it is set on Conf" do
            origin = Conf.utm_local_origin = Eigen::Vector3.new(1, 2, 3)
            driver_m = syskit_stub_driver_model(Dev::Sensors::MB500, :using => MB500Task, :as => 'dev')
            task = syskit_run_deployer(driver_m)
            syskit_setup_component(task)
            assert_equal origin, task.orocos_task.origin
        end
    end
end
