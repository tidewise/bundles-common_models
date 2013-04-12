require 'models/blueprints/devices'

Dev::Bus.com_bus_type 'CAN', :message_type => '/canbus/Message' do
    extend_attached_device_configuration do
        dsl_attribute :can_id do |id, mask|
            mask ||= id
            id   = Integer(id)
            mask = Integer(mask)
            if (id & mask) != id
                raise ArgumentError, "wrong id/mask combination: some bits in the ID are not set in the mask, and therefore the filter will never match"
            end
            [id, mask]
        end
    end
end


class Canbus::Task
    driver_for Dev::Bus::CAN, :as => 'driver'

    def configure
        super
        bus_name = self.canbus_name
        each_attached_device do |dev|
            can_id, can_mask = dev.can_id
            name = dev.name
            Robot.info "#{bus_name}: watching #{name} on 0x#{can_id.to_s(16)}/#{can_mask.to_s(16)}"
            orogen_task.watch(name, can_id, can_mask)
        end
    end
end

