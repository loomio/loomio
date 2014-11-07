class API::CommentsController < API::RestfulController
  before_filter :authenticate_user_by_email_api_key, only: :create
  before_filter :require_authenticated_user
  load_resource only: [:create, :update, :like, :unlike]

  def create
    CommentService.create(comment: @comment, actor: current_user)
    respond_with_resource
  end

  def update
    CommentService.update(comment: @comment, params: comment_params, actor: current_user)
    respond_with_resource
  end

  def like
    CommentService.like(comment: @comment, actor: current_user)
    respond_with_resource
  end

  def unlike
    CommentService.unlike(comment: @comment, actor: current_user)
    respond_with_resource
  end

  private
  def comment_params
    params.require(:comment).permit([:body, :new_attachment_ids, :uses_markdown, :discussion_id, :parent_id, {new_attachment_ids: []}])
  end
end
