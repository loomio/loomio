class Api::B2::DiscussionsController < Api::B2::BaseController
  def show
    self.resource = load_and_authorize(:discussion)
    respond_with_resource
  end

  def create
    instantiate_resource
    DiscussionService.create(actor: current_user, discussion: @discussion, params: params)
    respond_with_resource
  end
end
