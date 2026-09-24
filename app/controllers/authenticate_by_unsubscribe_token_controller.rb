class AuthenticateByUnsubscribeTokenController < ApplicationController
  before_action :authenticate_user_by_unsubscribe_token_or_fallback

  private

  def current_user
    @email_action_user || super
  end

  def authenticate_user_by_unsubscribe_token_or_fallback
    if params[:unsubscribe_token].present?
      @email_action_user = User.active.find_by(unsubscribe_token: params[:unsubscribe_token])
      head :forbidden unless @email_action_user
    else
      authenticate_user!
    end
  end
end
