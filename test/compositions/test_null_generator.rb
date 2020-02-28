# frozen_string_literal: true

require 'models/compositions/null_generator'

module CommonModels
    module Compositions
        describe NullGenerator do
            it "starts" do
                task = syskit_stub_deploy_configure_and_start(NullGenerator)
            end
        end
    end
end
