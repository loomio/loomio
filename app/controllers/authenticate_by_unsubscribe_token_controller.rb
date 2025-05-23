class AuthenticateByUnsubscribeTokenController < ApplicationController
  before_action :authenticate_user_by_unsubscribe_token_or_fallback

  private

  def current_user
    @restricted_user || super
  end

  def authenticate_user_by_unsubscribe_token_or_fallback
    unless (params[:unsubscribe_token].present? and @restricted_user = User.find_by_unsubscribe_token(params[:unsubscribe_token]))
      authenticate_user!
    end
  end
end
