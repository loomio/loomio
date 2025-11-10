class Api::B2::CommentsController < Api::B2::BaseController
  def create
    instantiate_resource
    if CommentService.create(comment: @comment, actor: current_user)
      respond_with_resource
    else
      respond_with_errors
    end
  end
end
