class API::B1::PollsController < API::B1::BaseController
  def show
    self.resource = load_and_authorize(:poll)
    respond_with_resource
  end

  def create
    instantiate_resource
    @poll.group_id = current_webhook.group_id
    if PollService.create(actor: current_user, poll: @poll)
      PollService.invite(actor: current_user, poll: @poll, params: params)
      respond_with_resource
    else
      respond_with_errors
    end
  end

  private
  def poll_attributes
    params.slice(*PermittedParams.new.poll_attributes).permit(*PermittedParams.new.poll_attributes)
  end
end
