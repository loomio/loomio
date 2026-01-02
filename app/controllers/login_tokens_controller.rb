class LoginTokensController < ApplicationController

  def show
    session[:pending_login_token] = login_token.token
    if Rails.env.development?
      redirect_to lmo_asset_host login_token.redirect || dashboard_path
    else
      redirect_to login_token.redirect || dashboard_path
    end
  end

  private

  def login_token
    @login_token ||= LoginToken.find_by!(token: params[:token])
  end
end
