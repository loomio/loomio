class API::B1::DiscussionsController < API::B1::BaseController
  def create
    @discussion = Discussion.new(params.slice(*PermittedParams.new.discussion_attributes).permit(*PermittedParams.new.discussion_attributes))
    @discussion.group_id = current_webhook.group_id
    DiscussionService.create(actor: current_user, discussion: @discussion)
    respond_with_resource
  end
end
