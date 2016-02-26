class API::CommentsController < API::RestfulController
  include UsesDiscussionReaders
  before_filter :authenticate_user_by_email_api_key, only: :create

  named_action :like
  named_action :unlike

  private

  def authenticate_user_by_email_api_key
    @current_user = User.find_by id:            request.headers['Loomio-User-Id'],
                                 email_api_key: request.headers['Loomio-Email-API-Key']
    head :unauthorized unless current_user.is_logged_in?
  end

end
