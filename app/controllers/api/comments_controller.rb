class Api::CommentsController < Api::BaseController
  respond_to :json

  def create
    @comment = Comment.new(permitted_params.comment)
    @comment.author = current_user
    @comment.discussion = Discussion.find(@comment.discussion_id)
    #@comment.discussion = Discussion.find(params[:comment][:discussion_id])
    authorize!(:create, @comment)
    @event = DiscussionService.add_comment(@comment)
    render 'api/events/show'
  end
end
