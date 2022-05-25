class API::V1::DemosController < API::V1::RestfulController
  before_action :require_current_user, only: [:clone]
  
  def index
    instantiate_collection
    respond_with_collection
  end

  def clone
    # require logged in user
    # find the demo id, and clone a group and put them in it

    demo = Demo.find(params[:id])
    clone = RecordCloner.new(recorded_at: demo.recorded_at)
                       .create_clone_group_for_actor(demo.group, current_user)
    self.collection = [clone]
    respond_with_collection
  end

  def accessible_records
    Demo.all
  end
end
