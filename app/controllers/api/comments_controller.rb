class API::CommentsController < API::RestfulController
  before_filter :authenticate_user_by_email_api_key, only: :create
  before_filter :require_authenticated_user

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
