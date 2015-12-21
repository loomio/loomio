class API::CommentsController < API::RestfulController
  include UsesDiscussionReaders
  before_filter :authenticate_user_by_email_api_key, only: :create

  load_resource only: [:like, :unlike]

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
    @current_user = User.find_by id:            request.headers['Loomio-User-Id'],
                                 email_api_key: request.headers['Loomio-Email-API-Key']
    head :unauthorized unless current_user.is_logged_in?
  end

end
