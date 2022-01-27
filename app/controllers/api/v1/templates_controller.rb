class API::V1::TemplatesController < API::V1::RestfulController
  before_action :require_current_user, only: [:clone]
  
  def index
    instantiate_collection
    respond_with_collection
  end

  def clone
    # require logged in user
    # find the demo id, and clone a group and put them in it

    template = Template.find(params[:id])
    clone = RecordCloner.new(recorded_at: template.recorded_at)
                       .create_clone_group_for_actor(template.record, current_user)
    clone.discussion_ids.each {|id| RepairThreadWorker.perform_async(id) }
    self.collection = [clone]
    respond_with_collection
  end

  def accessible_records
    Template.all
  end
end
