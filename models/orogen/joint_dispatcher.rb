require 'models/blueprints/control'

module JointDispatcher
    # Representation of a single dispatch in {Task}
    data_service_type 'DispatchedStatusSrv' do
        input_port 'status_in', '/base/samples/Joints'
        output_port 'status_out', '/base/samples/Joints'
        provides Base::JointsStatusSrv,
            'status_samples' => 'status_out'
    end

    # Composition that represents a dispatched set of joint providers
    #
    # It is usually not used directly, but specialized subclasses for it are
    # created by {multiplex} instead
    class Dispatch < Syskit::Composition
        add Task, :as => 'dispatcher'
    end

    def self.multiplex(*conf_names)
        dispatches = Task.port_dispatch(*conf_names)

        task = Task.specialize
        dispatches = dispatches.map do |input, output|
            srv = task.require_dynamic_service('dispatch', :as => "#{input}_#{output}", :status_in => input, :status_out => output)
            [input, output, srv]
        end

        Dispatch.new_submodel :name => "JointDispatcher::Dispatcher{#{conf_names.join(",")}}" do
            overload('dispatcher', task).
                with_conf(*conf_names)

            dispatches.each do |input, _, srv|
                child = add Base::JointsStatusSrv, :as => input
                child.connect_to dispatcher_child.find_data_service(srv.name)
            end

            dispatches.map { |_, output, _| output }.to_set.each do |output|
                export dispatcher_child.find_output_port(output)
                provides Base::JointsStatusSrv, :as => output
            end
        end
    end

    class Task
        dynamic_service DispatchedStatusSrv, :as => 'dispatch' do
            provides DispatchedStatusSrv, "status_in" => options[:status_in], "status_out" => options[:status_out]
            component_model.orogen_model.port_driven options[:status_in]
        end

        # @return [Array<(String,String)>] the dispatches represented at the port
        #   level, as a map from input ports to the corresponding output port
        def self.port_dispatch(*conf_names)
            conf = Orocos.conf.resolve('joint_dispatcher::Task', conf_names, true)
            conf['dispatches'].map do |dispatch|
                # The configuration objects are using typelib values, convert to
                # proper strings
                #
                # This workarounds a bug in oroGen, which does not call #to_str
                # whenever it expects a string
                [dispatch['input'].to_str, dispatch['output'].to_str]
            end
        end
    end
end

