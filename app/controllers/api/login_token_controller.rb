class Api::LoginTokenController < Api::RestfulController
  def show
    self.resource = resource_class.find_by(token: params[:id])
    if resource.useable?
      resource.update(used: true)
      sign_in resource.user
      flash[:notice] = t(:'devise.sessions.signed_in')
    else
      flash[:notice] = t(:'devise.sessions.expired_token')
    end
    redirect_to dashboard_path
  end
end
