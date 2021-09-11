class API::V1::DemosController < API::V1::RestfulController
  def create
    # require logged in user
    # find the demo id, and clone a group and put them in it

    demo = Demo.find(params[:id])
    clone = DemoService.new(recorded_at: demo.recorded_at)
                       .create_clone_group_for_actor(demo.group, current_user)

  end
end
