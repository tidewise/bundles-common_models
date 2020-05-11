# frozen_string_literal: true

import_types_from "base"

module Base
    module TimestamperManagement
        # The declared timestamp providers as a map from device name to a
        # provider definition
        #
        # See Timestamper.timestamp_provider
        attribute(:providers) { {} }

        # Declares that +provider+ should be used to provide timestamps for the
        # given devices
        def add_provider(provider, *device_names)
            device_names.each do |name|
                providers[name] = provider
            end
        end
    end

    data_service_type "TimestamperSrv" do
        output_port "timestamps", "/base/Time"
    end
    TimestamperSrv.extend TimestamperManagement

    data_service_type "TimestampInputSrv" do
        input_port "timestamps", "/base/Time"
    end

    Syskit::NetworkGeneration::Engine.register_instanciation_postprocessing do |engine, plan|
        providers_to_input = Hash.new { |h, k| h[k] = [] }

        # Avoid instanciating too many things by grouping providers together if they
        # provide timestamps for multiple outputs
        plan.find_local_tasks(TimestampInputSrv).each do |task|
            task.each_master_device do |dev|
                if provider = TimestamperSrv.providers[dev.full_name]
                    srv = task.find_data_service_from_type(TimestampInputSrv)
                    providers_to_input[provider] << srv
                end
            end
        end

        providers_to_input.each do |provider, services|
            provider = provider.instanciate(engine.work_plan)
            services.each do |srv|
                provider.timestamps_port.connect_to srv.timestamps_port
                srv.component.influenced_by(provider)
            end
        end
    end
end
