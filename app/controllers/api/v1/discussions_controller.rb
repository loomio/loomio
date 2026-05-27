class Api::V1::DiscussionsController < Api::V1::RestfulController
  def create
    self.resource = service.create(params: resource_params, actor: current_user)
    if resource_params[:forked_event_ids]&.any?
      EventService.move_comments(topic: resource.topic, params: resource_params, actor: current_user)
    end
    respond_with_resource
  end

  def show
    load_and_authorize(:discussion)
    accept_pending_membership
    respond_with_resource
  end
end
