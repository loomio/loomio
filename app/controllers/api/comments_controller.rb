class API::CommentsController < API::RestfulController
  skip_before_filter :require_authenticated_user

  before_filter :authenticate_user_by_email_api_key, only: :create
  before_filter :require_authenticated_user

  def like
    self.resource = CommentService.like(actor: current_user, params: params)
    respond_with_resource
  end

  def unlike
    self.resource = CommentService.unlike(actor: current_user, params: params)
    respond_with_resource
  end
end
