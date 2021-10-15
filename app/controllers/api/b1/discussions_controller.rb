class API::B1::DiscussionsController < API::B1::BaseController
  def show
    self.resource = load_and_authorize(:discussion)
    respond_with_resource
  end

  def create
    instantiate_resource
    @discussion.group_id = current_webhook.group_id
    DiscussionService.create(actor: current_user, discussion: @discussion)
    respond_with_resource
  end
end
