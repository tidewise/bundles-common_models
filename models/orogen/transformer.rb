# frozen_string_literal: true

Syskit.extend_model OroGen.transformer.Task do
    attr_reader :last_update

    poll do
        update_time, info = *plan.transformer_configuration_state
        if last_update != update_time
            orocos_task.setConfiguration(info)
            @last_update = update_time
        end
    end
end
