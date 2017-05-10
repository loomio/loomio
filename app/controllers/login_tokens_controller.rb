class LoginTokensController < ApplicationController

  def show
    if login_token.useable?
      login_token.update(used: true)
      sign_in(login_token.user || LoggedOutUser.new)
      flash[:notice] = t(:'devise.sessions.signed_in')
    else
      session[:pending_user_id] = login_token.user_id
      flash[:notice] = t(:"devise.sessions.token_unusable")
    end
    redirect_to dashboard_path
  end

  private

  def login_token
    @login_token ||= LoginToken.find_by!(token: params[:id])
  end
end
