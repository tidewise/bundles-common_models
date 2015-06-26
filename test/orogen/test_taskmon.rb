using_task_library 'taskmon'

module OroGen
module Taskmon
    describe Task do
        it { is_configurable }

        it "calls add_watches with the PID of the new deployments" do
            task = syskit_deploy_and_configure

            pids = [2]
            deployments = [flexmock(:pid => 2)]
            task.on :start do |event|
                flexmock(task.orocos_task).should_receive(:add_watches).
                    once.with(pids, [task.orocos_task])
                flexmock(task.query_deployments).should_receive(:to_set).
                    and_return(deployments.to_set)
            end
            task.start!
        end

        it "calls add_watches with the new orocos tasks" do
            task = syskit_deploy_and_configure

            tasks = [flexmock(:orocos_task => "bla")]
            task.on :start do |event|
                flexmock(task.orocos_task).should_receive(:add_watches).
                    once.with([], ["bla"])
                flexmock(task.query_deployments).should_receive(:to_set).
                    and_return(Set.new)
                flexmock(task.query_tasks).should_receive(:to_set).
                    and_return(tasks.to_set)
            end
            task.start!
        end
    end
end
end
