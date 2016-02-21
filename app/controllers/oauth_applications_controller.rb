class OauthApplicationsController < Doorkeeper::ApplicationsController
  include RootPathHelper
  include CurrentUserHelper
  before_filter :ensure_logged_in!

  def index
    @applications = Doorkeeper::Application.where(owner: current_user)
  end

  def show
    @application = Doorkeeper::Application.find(params[:id])
    head :forbidden unless @application.owner == current_user
  end

  private

  def ensure_logged_in!
    redirect_to new_user_session_path unless current_user_or_visitor.is_logged_in?
  end
end
