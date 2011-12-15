class Dynamixel::Task
    driver_for 'Dev::Dynamixel'

    on :start do |event|
        if Conf.initial_dynamixel_position? && orogen_task.mode == :POSITION
            orogen_task.setAngle(Conf.initial_dynamixel_position)
        end
    end
end

