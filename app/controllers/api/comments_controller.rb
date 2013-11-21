class Api::CommentsController < Api::BaseController
  respond_to :json

  def create
    @comment = Comment.new(permitted_params.comment)
    @comment.author = current_user
    raise @comment.inspect
    DiscussionService.add_comment(@comment)
    render 'api/comments/show'
  rescue Exception => e
    raise e.inspect

  end
end
