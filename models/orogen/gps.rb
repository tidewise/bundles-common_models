class Gps::MB500Task
    driver_for 'Dev::MB500' do
        provides Srv::Position
    end

    def configure
        super

        if Conf.utm_local_origin?
            orogen_task.origin = Conf.utm_local_origin
        end
    end
end

