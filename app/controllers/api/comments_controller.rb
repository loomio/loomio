class Api::CommentsController < Api::BaseController

  def create
    @comment = Comment.new(permitted_params.comment)
    @comment.author = current_user
    @comment.discussion = Discussion.find(@comment.discussion_id)
    @event = DiscussionService.add_comment(@comment)

    render_event_or_model_error(@event, @comment)
  end

  def like
    @comment = Comment.published.find(params[:id])
    DiscussionService.like_comment(current_user, @comment)
    render json: {id: current_user.id, name: current_user.name}
  end

  def unlike
    @comment = Comment.published.find(params[:id])
    DiscussionService.unlike_comment(current_user, @comment)
    render json: {id: current_user.id}
  end
end
