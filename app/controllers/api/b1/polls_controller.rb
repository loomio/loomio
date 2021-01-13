class API::B1::PollsController < API::B1::BaseController
  def create
    @poll = Poll.new(params.slice(*PermittedParams.new.poll_attributes).permit(*PermittedParams.new.poll_attributes))
    @poll.group_id = current_webhook.group_id
    PollService.create(actor: current_user, poll: @poll)
    respond_with_resource
  end
end
