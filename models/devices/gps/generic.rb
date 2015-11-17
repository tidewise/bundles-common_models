# Load the relevant typekits with import_types_from
# import_types_from 'base'
# You MUST require files that define services that
# you want Generic to provide

module Rock
    module Devices
        module GPS
            device_type 'Generic' do
                # input_port 'in', '/base/Vector3d'
                # output_port 'out', '/base/Vector3d'
                #
                # Tell syskit that this service provides another. It adds the 
                # ports from the provided service to this service
                # provides AnotherSrv
                #
                # Tell syskit that this service provides another. It maps ports
                # from the provided service to the one in this service (instead
                # of adding)
                # provides AnotherSrv, 'provided_srv_in' => 'in'

                # # Device models can define configuration extensions, which
                # # extend the additconfiguration capabilities of the device
                # # objects, for instance with
                # extend_device_configuration do
                #     # Communication baudrate in bit/s
                #     dsl_attribute :baudrate do |value|
                #         Float(value)
                #     end
                # end
                # # One can do the following in the robot description:
                # # robot do
                # #     device(Generic).
                # #         baudrate(1_000_000) # Use 1Mbit/s
                # # end
                # # 
                # # and then use the information to auto-configure the device
                # # drivers
                # # class OroGen::MyDeviceDriver::Task
                # #     driver_for Generic, as: 'driver'
                # #     def configure
                # #         super
                # #         orocos_task.baudrate = robot_device.baudrate
                # #     end
                # # end
                # #
                # # NOTE: this should be limited to device-specific configurations
                # # NOTE: driver-specific parameters must be set in the corresponding
                # # NOTE: oroGen configuration file
            end
        end
    end
end
