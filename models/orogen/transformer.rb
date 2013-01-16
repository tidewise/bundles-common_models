class Transformer::Task
    attr_reader :last_update

    poll do
        update_time, info = *Roby.app.orocos_engine.transformer_configuration_state
        if last_update != update_time
            orogen_task.setConfiguration(info)
            Typelib.copy(Orocos.transformer.configuration_state, info)
            @last_update = update_time
        end
    end
end

