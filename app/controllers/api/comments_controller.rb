class Api::CommentsController < Api::BaseController
  respond_to :json

  def create
    @comment = Comment.new(permitted_params.comment)
    @comment.author = current_user
    DiscussionService.add_comment(@comment)
    render 'api/comments/show'
  end
end
