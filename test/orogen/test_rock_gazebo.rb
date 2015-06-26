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
        end
    end
end
