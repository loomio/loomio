class API::LoginTokensController < API::RestfulController
  def create
    service.create(actor: User.find_by(email: params.require(:email)))
    head :ok
  end

  def show
    if token = resource_class.useable.find_by(token: params[:id])
      token.update(used: true)
      sign_in token.user
      flash[:notice] = t(:'devise.sessions.signed_in')
    else
      flash[:notice] = t(:"devise.sessions.token_unusable")
    end
    redirect_to dashboard_path
  end
end
