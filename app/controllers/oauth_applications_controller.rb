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

  def application_params
    params.require(:doorkeeper_application)
          .permit(:name, :redirect_uri, :scopes)
          .merge(owner_id: current_user_or_visitor.id, owner_type: :User)
  end

  def ensure_logged_in!
    redirect_to new_user_session_path unless current_user_or_visitor.is_logged_in?
  end
end
