com_bus_type 'GPIOReader', :message_type => '/parport/StateChange', :override_policy => false
parport_t = com_bus_type 'Parport' do
    provides Dev::GPIOReader
end
parport_t.extend_attached_device_configuration do
    dsl_attribute :parport_pin do |pin_id|
        Integer(pin_id)
    end
end

class Parport::Task
    driver_for Dev::Parport

    def configure
        super
        bus_name = self.parport_name
        each_attached_device do |dev|
            pin = dev.parport_pin
            name = dev.name
            Robot.info "#{bus_name}: watching #{name} on #{pin}"
            orogen_task.watch_pin(name, pin)
        end
    end
end

