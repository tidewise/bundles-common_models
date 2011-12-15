class Hokuyo::Task
    driver_for 'Dev::Hokuyo' do
        provides Srv::LaserRangeFinder
    end
    provides Srv::TimestampInput
end

