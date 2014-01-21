using_task_library 'taskmon'

module Taskmon
    describe Task do
        it_should_be_configurable

        it "calls add_watches with the PID of the new deployments" do
            stub_syskit_deployment_model(Task, 'task')
            task = syskit_run_deployer(Task)
            syskit_setup_component(task)

            pids = [2]
            deployments = [flexmock(:pid => 2)]
            task.on :start do |event|
                flexmock(task.orocos_task).should_receive(:add_watches).
                    once.with(pids, [task.orocos_task])
                flexmock(task.query_deployments).should_receive(:to_value_set).
                    and_return(deployments.to_value_set)
            end
            task.start!
            process_events
            process_events
        end

        it "calls add_watches with the new orocos tasks" do
            stub_syskit_deployment_model(Task, 'task')
            task = syskit_run_deployer(Task)
            syskit_setup_component(task)

            tasks = [flexmock(:orocos_task => "bla")]
            task.on :start do |event|
                flexmock(task.orocos_task).should_receive(:add_watches).
                    once.with([], ["bla"])
                flexmock(task.query_deployments).should_receive(:to_value_set).
                    and_return(ValueSet.new)
                flexmock(task.query_tasks).should_receive(:to_value_set).
                    and_return(tasks.to_value_set)
            end
            task.start!
            process_events
            process_events
        end
    end
end
