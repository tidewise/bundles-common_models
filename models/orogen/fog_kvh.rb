using_task_library "fog_kvh"

Dev::Sensors.device_type 'FOG' do
    provides Base::RotationSrv#, :as => 'rotation'
end

class FogKvh::Dsp3000Task
  driver_for Dev::Sensors::FOG, :as => 'driver'
  def configure
    super
    period = (robot_def.period * 1000).round
  end
end
