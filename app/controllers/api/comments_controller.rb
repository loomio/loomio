class API::CommentsController < API::RestfulController
  include UsesDiscussionReaders
  before_filter :authenticate_user_by_email_api_key, only: :create

  load_resource only: [:like, :unlike]
  before_filter :require_authenticated_user

  def like
    CommentService.like(comment: @comment, actor: current_user)
    respond_with_resource
  end

  def unlike
    CommentService.unlike(comment: @comment, actor: current_user)
    respond_with_resource
  end

  private

  def authenticate_user_by_email_api_key
    user_id = request.headers['Loomio-User-Id']
    key = request.headers['Loomio-Email-API-Key']
    @current_user = User.where(id: user_id, email_api_key: key).first
  end
end
