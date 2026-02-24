class Api::B2::PollsController < Api::B2::BaseController
  def show
    self.resource = load_and_authorize(:poll)
    respond_with_resource
  end

  def create
    self.resource = PollService.create(params: resource_params, actor: current_user)
    PollService.invite(poll: resource, actor: current_user, params: params)
    respond_with_resource
  end
end
