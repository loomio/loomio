class Api::B2::DiscussionsController < Api::B2::BaseController
  def show
    self.resource = load_and_authorize(:discussion)
    respond_with_resource
  end

  def create
    self.resource = DiscussionService.create(params: resource_params, actor: current_user)
    respond_with_resource
  end
end
