class Stereo::Task
    # Additional information to allow for the transformer's automatic
    # configuration
    transformer do
        associate_frame_to_ports 'lcamera', 'distance_frame'
    end
    
end

composition 'StereoProcessing' do
    add Stereo::Task, :as => 'stereotask'
    
    add Srv::ImageProvider, :as => 'left'
    add Srv::ImageProvider, :as => 'right'
    autoconnect
    
    export stereotask.distance_frame
    provides Srv::DistanceImageProvider
end