import_types_from 'base'

# Abstract data service that every component that has a controller role in a
# control loop should provide
data_service_type 'Controller'
# Abstract data service that every component that has a controlled system role
# in a control loop should provide
data_service_type 'ControlledSystem'

# Abstract base composition for all control loops
composition 'ControlLoop' do
    abstract

    add Srv::Controller
    add Srv::ControlledSystem

    add_specialization_constraint do |spec0, spec1|
        %w{controller controlled_system}.all? do |child_name|
            if !(spec0.has_specialization?(child_name, Srv::Controller) && spec1.has_specialization?(child_name, Srv::Controller))
                !(spec0.has_specialization?(child_name, Srv::ControlledSystem) && spec1.has_specialization?(child_name, Srv::ControlledSystem))
            end
        end
    end

    # Common implementation of control loop declarations
    #
    # Given a name of ControlLoopType, it declares:
    #
    #  * two data services named ControlLoopTypeController and
    #    ControlLoopTypeControlledSystem. The first one is the
    #    Srv::Controller and the second one the Srv::ControlledSystem
    #  * it declares the relevant specializations on Cmp::ControlLoop
    #
    # Optionally, if a :feedback_type option is given, a feedback channel is
    # created between the controller and the controlled system, of the provided
    # type
    def self.declare(name, control_type, options = Hash.new)
        options = Kernel.validate_options options, :feedback_type
        feedback_type = options[:feedback_type]

        controller_model = system_model.data_service_type "#{name}Controller" do
            provides Srv::Controller
            output_port "command_out", control_type
            if feedback_type
                input_port "status_in", feedback_type
            end
        end
        controlled_system_model = system_model.data_service_type "#{name}ControlledSystem" do
            provides Srv::ControlledSystem
            input_port "command_in", control_type
            if feedback_type
                output_port "status_out", feedback_type
            end
        end
        specialize 'controller' => controlled_system_model do
            export controller.command_in
            if feedback_type
                export controller.status_out
            end
            provides controlled_system_model
            autoconnect
        end
        specialize 'controller' => controller_model, 'controlled_system' => controlled_system_model do
            autoconnect
        end
    end
end
