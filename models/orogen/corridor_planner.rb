# Integration of the corridor planner task
#
# The task can take its start and end point by two means:
#  * either directly, as a task argument
#  * or by reading it from its planned task (if the task is used as a planning
#    task)
class CorridorPlanner::Task
    argument :start_point, :default => from(:planned_task).start_point.of_type(Eigen::Vector3)
    argument :target_point, :default => from(:planned_task).target_point.of_type(Eigen::Vector3)

    def configure
        super
        if Conf.traversability_map_file?
            orogen_task.map_path = Conf.traversability_map_file
        end
        orogen_task.terrain_classes = Conf.traversability_classes_file
        orogen_task.strong_edge_filter do |p|
            p.env_path = Conf.environment_map_path
        end
    end

    event :start do |context|
        orogen_task.start_point   = self.start_point
        orogen_task.target_point  = self.target_point
        @result_reader = data_reader 'plan'

        super(context)
    end

    on :success do |context|
        # Forcefully read the result, as the data reader will get disconnected
        # when the task stops
        result
    end
    
    def write_map(map)
	#TODO write map on port
    end

    # Returns the resulting plan, if there is one
    def result
        if @result_reader
            @result ||= @result_reader.read_new
        end
    end
end

class CorridorPlanner::Traversability
    event :start do |context|
        @result_reader = data_reader 'traversability_map'

        super(context)
    end

    on :success do |context|
        # Forcefully read the result, as the data reader will get disconnected
        # when the task stops
        result
    end
    
    # Returns the resulting plan, if there is one
    def result
        if @result_reader
            @result ||= @result_reader.read_new
        end
    end
end