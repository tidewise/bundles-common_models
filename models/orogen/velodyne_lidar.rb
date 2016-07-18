require 'rock/models/blueprints/devices'

module VelodyneLidar
    class LaserScanner
        driver_for Dev::Sensors::Velodyne, :as => 'driver',
            'depth_map' => 'laser_scans'
    end
end
