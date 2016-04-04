class API::CommentsController < API::RestfulController
  include UsesDiscussionReaders
  load_resource only: [:like, :unlike]

  def like
    CommentService.like(comment: @comment, actor: current_user)
    respond_with_resource
  end

  def unlike
    CommentService.unlike(comment: @comment, actor: current_user)
    respond_with_resource
  end
end
