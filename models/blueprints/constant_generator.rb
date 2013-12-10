module Rock
    class ConstantGenerator < Syskit::RubyTaskContext
        argument :values

        def values=(setpoint)
            setpoint.each do |port_name, _|
                if !find_port(port_name)
                    raise ArgumentError, "#{port_name} is not a known port of #{self}."
                end
            end
            arguments[:values] = setpoint
        end

        poll do
            values.each do |port_name, value|
                orocos_task.port(port_name).write value
            end
        end

        def self.for(object)
            if object.respond_to?(:to_str)
                return for_type(object)
            else
                return for_data_service(object)
            end
        end

        def self.for_type(type_name)
            generator = ConstantGenerator.new_submodel
            generator.output_port 'out', type_name
            generator
        end

        def self.for_data_service(service_model)
            if service_model.const_defined_here?('Generator')
                return service_model.const_get(:Generator)
            end

            generator = ConstantGenerator.new_submodel
            service_model.each_input_port do |port|
                generator.input_port port.name, port.orocos_type_name
            end
            service_model.each_output_port do |port|
                generator.output_port port.name, port.orocos_type_name
            end
            generator.provides service_model, :as => 'srv'
            service_model.const_set :Generator, generator
            generator
        end
    end
end
