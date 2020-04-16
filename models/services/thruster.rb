# frozen_string_literal: true

import_types_from "base"

module CommonModels
    module Services
        data_service_type "Thruster" do
            input_port "command_in", "/base/samples/Joints"
        end
        data_service_type "ThrusterController" do
            output_port "command_out", "/base/samples/Joints"
        end
    end
end
