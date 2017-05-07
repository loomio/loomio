class LoginTokensController < ApplicationController
  include PendingActionsHelper

  def show
    if token = LoginToken.useable.find_by(token: params[:id])
      token.update(used: true)
      sign_in token.user
      handle_pending_actions
      flash[:notice] = t(:'devise.sessions.signed_in')
    else
      flash[:notice] = t(:"devise.sessions.token_unusable")
    end
    redirect_to dashboard_path
  end
end
