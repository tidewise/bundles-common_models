# frozen_string_literal: true

# OroGen.logger already exists, we can't access the model for logger::Logger
# using the method syntax
logger_m = OroGen.syskit_model_by_orogen_name("logger::Logger")

Syskit.extend_model logger_m do
    provides Syskit::LoggerService

    # Customizes the configuration step.
    #
    # The orocos task is available from orocos_task
    #
    # The call to super here applies the configuration on the orocos task. If
    # you need to override properties, do it afterwards
    #
    # def configure
    #     super
    # end

    def update_properties
        super
        properties.overwrite_existing_files = false
        properties.auto_timestamp_files = false
    end

    def rotate_log
        previous_file = properties.file

        Syskit::NetworkGeneration::LoggerConfigurationSupport.setup_default_logger(self)

        previous_file.empty? ? [] : [previous_file]
    end
end