# frozen_string_literal: true


module CommonModels
    module Compositions
        # Generic implementation of a component with input/output ports that generates
        # ... nothing
        class NullGenerator < Syskit::RubyTaskContext
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
                service_model, register: false, as: 'template'
            )
                if register && service_model.const_defined_here?('Generator')
                    return service_model.const_get(:NullGenerator)
                end

                generator = NullGenerator.new_submodel
                service_model.each_input_port do |port|
                    generator.input_port port.name, port.orocos_type_name
                end
                service_model.each_output_port do |port|
                    generator.output_port port.name, port.orocos_type_name
                end
                generator.provides service_model, as: as
                service_model.const_set :NullGenerator, generator if register
                generator
            end
        end
    end
end
