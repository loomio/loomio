class Api::B2::PollsController < Api::B2::BaseController
  def show
    self.resource = load_and_authorize(:poll)
    respond_with_resource
  end

  def create
    result = PollService.create(params: resource_params, actor: current_user)
    @event = result[:event]
    self.resource = result[:poll]
    if result[:event]
      PollService.invite(actor: current_user, poll: @poll, params: params)
      respond_with_resource
    else
      respond_with_errors
    end
  end
end
