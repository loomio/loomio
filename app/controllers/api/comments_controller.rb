class API::CommentsController < API::BaseController
  before_filter :authenticate_user_by_email_api_key, only: :create
  before_filter :require_authenticated_user
  respond_to :json

  def create
    comment = Comment.new(permitted_params.comment)
    comment.author = current_user
    comment.discussion = Discussion.find(params[:comment][:discussion_id])
    event = DiscussionService.add_comment(comment)
    head :ok
  end
end
