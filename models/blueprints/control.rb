import_types_from 'base'

module Base
    # Abstract data service that every component that has a controller role in a
    # control loop should provide
    data_service_type 'ControllerSrv'
    # Abstract data service that every component that has a controlled system role
    # in a control loop should provide
    data_service_type 'ControlledSystemSrv'

    # Abstract base composition for all control loops
    class ControlLoop < Syskit::Composition
        abstract

        add ControllerSrv, :as => 'controller'
        add ControlledSystemSrv, :as => 'controlled_system'

        add_specialization_constraint do |spec0, spec1|
            %w{controller controlled_system}.all? do |child_name|
                controller0 = spec0.find_specialization(child_name, ControllerSrv)
                controller1 = spec1.find_specialization(child_name, ControllerSrv)
                if controller0 && controller1
                    m0 = controller0.first
                    m1 = controller1.first
                    if !m0.fullfills?(m1) && !m1.fullfills?(m0)
                        next(false)
                    end
                end

                controlled0 = spec0.find_specialization(child_name, ControlledSystemSrv)
                controlled1 = spec1.find_specialization(child_name, ControlledSystemSrv)
                if controlled0 && controlled1
                    m0 = controlled0.first
                    m1 = controlled1.first
                    if !m0.fullfills?(m1) && !m1.fullfills?(m0)
                        next(false)
                    end
                end

                true
            end
        end

        # Common implementation of control loop declarations
        #
        # Given a name of ControlLoopType, it declares:
        #
        #  * two data services named #{name}Controller and #{name}ControlledSystem.
        #    The first one is providing Base::ControllerSrv and the second one is
        #    providing Base::ControlledSystemSrv
        #  * it declares the relevant specializations on Cmp::ControlLoop
        #
        # Optionally, if a :feedback_type option is given, a feedback channel is
        # created between the controller and the controlled system, of the provided
        # type
        #
        # If you expand what this method does for
        #
        #   Cmp::ControlLoop.declare "Actuator", 'base/actuators/Command',
        #       :feedback_type => 'base/actuators/Status'
        #
        # it is
        #
        #   data_service_type "ActuatorController" do
        #       provides Base::ControllerSrv
        #       output_port 'command_out'
        #       input_port 'status_in'
        #   end
        #   data_service_type "ControlledSystem" do
        #       provides Base::ControlledSystemSrv
        #       input_port 'command_in'
        #       output_port 'status_out'
        #   end
        #   ControlLooop.specialize Base::ControlledSystemSrv do
        #       export controller.command_in
        #       if feedback_type
        #           export controller.status_out
        #       end
        #       provides controlled_system_model
        #   end
        #   ControlLooop.specialize Base::ControllerSrv do
        #   end
        #
        def self.declare(name, control_type, options = Hash.new)
            options = Kernel.validate_options options, :feedback_type
            feedback_type = options[:feedback_type]

            controller_model = Base.data_service_type "#{name}ControllerSrv" do
                provides Base::ControllerSrv
                output_port "command_out", control_type
                if feedback_type
                    input_port "status_in", feedback_type
                end
            end
            controlled_system_model = Base.data_service_type "#{name}ControlledSystemSrv" do
                provides Base::ControlledSystemSrv
                input_port "command_in", control_type
                if feedback_type
                    output_port "status_out", feedback_type
                end
            end
            specialize 'controller' => controlled_system_model do
                export controller_child.command_in_port
                if feedback_type
                    export controller_child.status_out_port
                end
                provides controlled_system_model, :as => "#{name}"
            end
            specialize 'controller' => controller_model, 'controlled_system' => controlled_system_model do
                connect controller_child => controlled_system_child
                if feedback_type
                    connect controlled_system_child => controller_child
                end
            end
        end
    end

    # This declares an ActuatorController and ActuatorControlledSystem data service
    # types, and the necessary specializations on Cmp::ControlLoop
    ControlLoop.declare "Actuator", 'base/actuators/Command',
        :feedback_type => 'base/actuators/Status'


    # This declares an Motion2DController and Motion2DControlledSystem data service
    # types, and the necessary specializations on Cmp::ControlLoop
    ControlLoop.declare "Motion2D", 'base/MotionCommand2D'
end

