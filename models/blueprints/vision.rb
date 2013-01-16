require 'models/blueprints/sensors'
using_task_library 'stereo'

module Rock
    module Sensors
        # Integration of the stereo processing task
        class StereoProcessing < Syskit::Composition
            add Stereo::Task, :as => 'processing'

            add Rock::Base::ImageProviderSrv, :as => 'left'
            add Rock::Base::ImageProviderSrv, :as => 'right'

            left_child.frame_port.connect_to processing_child.left_frame_port
            right_child.frame_port.connect_to processing_child.right_frame_port

            export processing_child.distance_frame_port
            provides Rock::Base::DistanceImageProviderSrv, :as => 'distance_image'
        end
    end
end

