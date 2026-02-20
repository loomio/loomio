class Api::B2::DiscussionsController < Api::B2::BaseController
  def show
    self.resource = load_and_authorize(:discussion)
    respond_with_resource
  end

  def create
    result = DiscussionService.create(actor: current_user, params: resource_params)
    self.resource = result[:discussion]
    respond_with_resource
  end
end
