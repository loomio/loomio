class API::B2::PollsController < API::B2::BaseController
  def show
    self.resource = load_and_authorize(:poll)
    respond_with_resource
  end

  def create
    instantiate_resource
    if PollService.create(actor: current_user, poll: @poll, params: params)
      PollService.invite(actor: current_user, poll: @poll, params: params)
      respond_with_resource
    else
      respond_with_errors
    end
  end
end
