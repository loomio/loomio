class API::V1::DemosController < API::V1::RestfulController
  before_action :require_current_user, only: [:clone]
  
  def index
    instantiate_collection
    respond_with_collection
  end

  def clone
    # require logged in user
    # find the demo id, and clone a group and put them in it

    if params[:id]
      demo = Demo.find(params[:id])
    elsif params[:group_id]
      demo = Demo.find_by!(group_id: params[:group_id])
    elsif params[:handle]
      demo = Demo.find_by!(demo_handle: params[:handle])
    else
      raise "no params"
    end

    clone = RecordCloner.new(recorded_at: demo.recorded_at)
                       .create_clone_group_for_actor(demo.group, current_user)
    self.collection = [clone]
    respond_with_collection
  end

  def accessible_records
    Demo.all
  end
end
