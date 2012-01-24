import_types_from 'base'
data_service_type 'Timestamper' do
    output_port 'timestamps', '/base/Time'
end
data_service_type 'TimestampInput' do
    input_port 'timestamps', '/base/Time'
end
timestamper_device = device_type 'Timestamper' do
    provides Srv::Timestamper
end
module Srv::Timestamper
    class << self
        # The declared timestamp providers as a map from device name to a
        # provider definition
        #
        # See Timestamper.timestamp_provider
        attr_reader :providers
    end
    @providers = Hash.new

    # Declares that +provider+ should be used to provide timestamps for the
    # given devices
    def self.add_provider(provider, *device_names)
        device_names.each do |name|
            providers[name] = provider
        end
    end
end

timestamper_device.extend_device_configuration do
    def timestamper_for(*device_names)
        Srv::Timestamper.add_provider(self.full_name, *device_names)
    end
end

Engine.register_instanciation_postprocessing do |engine, plan|
    providers_to_input = Hash.new { |h, k| h[k] = Array.new }

    # Avoid instanciating too many things by grouping providers together if they
    # provide timestamps for multiple outputs
    plan.find_tasks(Srv::TimestampInput).each do |task|
        task.each_device_name do |srv, name|
            if provider = Srv::Timestamper.providers[name]
                srv = task.model.find_service_from_type(Srv::TimestampInput)
                providers_to_input[provider] << Orocos::RobyPlugin::DataServiceInstance.new(task, srv)
            end
        end
    end

    providers_to_input.each do |provider, services|
        task = engine.add_instance(provider)
        services.each do |srv|
            task.as(Srv::Timestamper).connect_ports(srv, ['timestamps', 'timestamps'] => Hash.new)
            srv.task.influenced_by(task)
        end
    end
end

