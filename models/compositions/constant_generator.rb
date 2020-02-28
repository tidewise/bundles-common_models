
module CommonModels
    module Compositions
        # Generic implementation of components that generate constant values on
        # their ports
        #
        # A specific constant generator task can be generated from the name of a
        # data type with {ConstantGenerator.for_type}. It can also be generated from
        # a data service model with {ConstantGenerator.for_data_service}. In the
        # first case, the port name will always be 'out'. In the second case, the
        # task will have the same ports than the data service (including input
        # ports).
        #
        # The values that should be generated are passed through the {values}
        # argument.
        #
        # @example create and deploy a task that generates a constant double value of 0.2
        #   DoubleGenerator = ConstantGenerator.for_type('/double')
        #   Syskit.conf.use_ruby_tasks DoubleGenerator => 'double_gen'
        #   add_mission DoubleGenerator.with_arguments(:values => Hash['out' => 10])
        class ConstantGenerator < Syskit::RubyTaskContext
            # Values that should be pushed on the ports
            #
            # This is a hash of port names to the values
            #
            # @return [{String=>Object}]
            argument :values

            # The write period in seconds
            argument :period, default: 0.1

            # @api private
            #
            # The writing thread
            attr_reader :write_thread

            class << self
                def time_fields
                    fields = (@time_fields ||= {})
                    if defined?(super)
                        fields.merge(super)
                    else
                        fields
                    end
                end

                attr_writer :time_fields
            end

            def initialize(**arguments)
                super
                @time_setters = self.class.time_fields
                                    .transform_values { |n| "#{n}=" }
                                    .transform_keys(&:to_s)
            end

            # Sets the {#values} argument
            def values=(setpoint)
                setpoint = setpoint.transform_keys(&:to_s)

                # Sanity checks
                setpoint.each do |port_name, value|
                    # Check that the port exists
                    unless find_port(port_name)
                        raise ArgumentError, "#{port_name} is not a known port of #{self}"
                    end

                    # Check that the value is valid (can be converted)
                    Typelib.from_ruby(value, find_port(port_name).type)
                end
                arguments[:values] = setpoint
            end

            # Modify the generator value just before it is written
            def filter_value(port_name, value)
                if (setter = @time_setters[port_name])
                    value = value.dup
                    value.send(setter, Time.now)
                end

                value
            end

            event :start do |context|
                @write_thread_exit = exit_event = Concurrent::Event.new
                period = self.period
                @write_thread = Thread.new do
                    until exit_event.set?
                        values.each do |port_name, value|
                            value = filter_value(port_name, value)
                            orocos_task.port(port_name).write(value)
                        end
                        exit_event.wait(period)
                    end
                end
                super(context)
            end

            event :write_thread_error
            signal :write_thread_error => :interrupt

            poll do
                unless @write_thread.alive?
                    begin
                        result = @write_thread.value
                        write_thread_error_event.emit(result) unless stop_event.pending?
                    rescue ::Exception => e
                        write_thread_error_event.emit(e)
                    end
                end
            end

            event :stop do |context|
                @write_thread_exit.set
                begin
                    @write_thread.join
                rescue ::Exception
                end
                super(context)
            end

            # Shortcut for {for_type} and {for_data_service}
            #
            # It dispatches based on the argument type
            def self.for(object)
                if Syskit::Models.is_model?(object)
                    for_data_service(object)
                else
                    for_type(object)
                end
            end

            # Create a ConstantGenerator for a given data type
            #
            # The generated task model has a single 'out' port of the required type
            #
            # It will return different models if called twice from the same data
            # type. This means that you can't use it as-is in e.g. a composition
            # definition, you must assign it first to a constant, and use the
            # constant
            #
            #   DoubleGenerator = ConstantGenerator.for_type '/double'
            #   # From now on, use DoubleGenerator
            #
            # @return [Model<ConstantGenerator>]
            def self.for_type(type_name, time_field: nil)
                generator = ConstantGenerator.new_submodel
                generator.time_fields =
                    if time_field
                        { 'out' => time_field }
                    else
                        {}
                    end

                port = generator.output_port 'out', type_name
                port.doc 'The generated value, from the values argument to the task. '\
                         'Set it to a hash with a single out key and the value to '\
                         'generate.'
                generator
            end

            # Create a ConstantGenerator for a given data service
            #
            # The generated task model has the same ports than the data service
            #
            # Given a data service, the returned value will always be identical. If
            # you want to customize the model in different ways, subclass it. For
            # instance:
            #
            #   ImageGenerator = ConstantGenerator.for_data_service(Base::ImageSrv)
            #   class AutoStopGenerator < ImageGenerator
            #      poll do
            #        if lifetime > 5
            #          stop_event.emit
            #        end
            #      end
            #   end
            #
            # @return [Model<ConstantGenerator>]
            def self.for_data_service(
                service_model, time_fields: {}, register: true, as: 'template'
            )
                if register && service_model.const_defined_here?('Generator')
                    return service_model.const_get(:Generator)
                end

                generator = for_data_services({ service_model => as },
                                              time_fields: time_fields,
                                              map_port_names: map_port_names)

                service_model.const_set :Generator, generator if register
                generator
            end

            def self.validate_time_fields(component_m, time_fields)
                time_fields.each do |port_name, field_name|
                    unless (p = component_m.find_output_port(port_name))
                        raise ArgumentError,
                              "port #{port_name} is not an output port of the "\
                              'created generator. If you set map_port_names, remember '\
                              'to also map the port names in time_fields'
                    end

                    unless p.type.has_field?(field_name.to_sym)
                        raise ArgumentError,
                              "'#{field_name}' is not a field of #{p.type}, type of "\
                              "port #{port_name}"
                    end
                end
            end

            def self.for_data_services(
                service_models, map_port_names: false, time_fields: {}
            )
                generator = ConstantGenerator.new_submodel

                port_transform_names =
                    if map_port_names
                        ->(as, n) { "#{as}_#{n}" }
                    else
                        ->(_, n) { n }
                    end


                known_ports = Set.new
                service_models.each do |srv_m, as|
                    srv_m.each_input_port do |port|
                        port_name = port_transform_names.call(as, port.name)
                        unless known_ports.add?(port_name)
                            raise ArgumentError,
                                  "#{port_name} already defined, use map_port_names "\
                                  'to avoid collisions'
                        end
                        generator.input_port port_name, port.orocos_type_name
                    end
                    srv_m.each_output_port do |port|
                        port_name = port_transform_names.call(as, port.name)
                        unless known_ports.add?(port_name)
                            raise ArgumentError,
                                  "#{port_name} already defined, use map_port_names "\
                                  'to avoid collisions'
                        end
                        generator.output_port port_name, port.orocos_type_name
                    end
                    generator.provides srv_m, as: as
                end

                validate_time_fields(generator, time_fields)
                generator.time_fields = time_fields

                generator
            end
        end
    end
end
