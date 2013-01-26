import_types_from 'base'

module Base
    module TimestamperManagement
        # The declared timestamp providers as a map from device name to a
        # provider definition
        #
        # See Timestamper.timestamp_provider
        attribute(:providers) { Hash.new }

        # Declares that +provider+ should be used to provide timestamps for the
        # given devices
        def add_provider(provider, *device_names)
            device_names.each do |name|
                providers[name] = provider
            end
        end
    end

    data_service_type 'TimestamperSrv' do
        output_port 'timestamps', '/base/Time'
    end
    TimestamperSrv.extend TimestamperManagement

    data_service_type 'TimestampInputSrv' do
        input_port 'timestamps', '/base/Time'
    end

    device_type 'TimestamperDev' do
        provides TimestamperSrv

        extend_device_configuration do
            def timestamper_for(*device_names)
                TimestamperSrv.add_provider(self.full_name, *device_names)
            end
        end
    end

    Syskit::NetworkGeneration::Engine.register_instanciation_postprocessing do |engine, plan|
        providers_to_input = Hash.new { |h, k| h[k] = Array.new }

        # Avoid instanciating too many things by grouping providers together if they
        # provide timestamps for multiple outputs
        plan.find_local_tasks(TimestampInputSrv).each do |task|
            task.each_master_device do |dev|
                if provider = TimestamperSrv.providers[dev.full_name]
                    srv = task.model.find_data_service_from_type(TimestampInputSrv)
                    providers_to_input[provider] << srv.bind(task)
                end
            end
        end

        providers_to_input.each do |provider, services|
            task = provider.instanciate(engine.work_plan)
            services.each do |srv|
                task.as(TimestamperSrv).timestamps_port.connect_to srv.timestamps_port
                srv.task.influenced_by(task)
            end
        end
    end
end

