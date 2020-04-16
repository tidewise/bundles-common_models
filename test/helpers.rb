# frozen_string_literal: true

module Helpers
    def stub_sdf
        @original_sdf = Conf.sdf
        Conf.sdf = RockGazebo::Syskit::SDF.new
    end

    def restore_sdf
        Conf.sdf = @original_sdf
        @original_sdf = nil
    end

    def stub_sdf_world_file_path
        stub_sdf
        Conf.sdf.world_file_path = "/world/file"
    end

    def teardown
        super
        if @original_sdf
            restore_sdf
        end
    end
end
Minitest::Spec.include Helpers
