class API::CommentsController < API::BaseController
  before_filter :authenticate_user_by_email_api_key, only: :create
  before_filter :require_authenticated_user
  respond_to :json

  def create
    # this should be permitted_params.api_comment when we get around to it.
    comment = Comment.new(permitted_params.comment)
    comment.author = current_user
    comment.discussion = Discussion.find(params[:comment][:discussion_id])
    event = DiscussionService.add_comment(comment)
    head :ok
  end

  def like
    @comment = Comment.find(params[:id])
    DiscussionService.like_comment(current_user, @comment)
    render json: {id: current_user.id}
  end

  def unlike
    @comment = Comment.find(params[:id])
    DiscussionService.unlike_comment(current_user, @comment)
    render json: {id: current_user.id}
  end
end
