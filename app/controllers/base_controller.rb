class BaseController < ApplicationController
  include OmniauthAuthenticationHelper

  before_filter :authenticate_user!

  before_filter :check_for_omniauth_authentication,
                :check_for_invitation

  protected

  def ajax_request?
    request.xhr? or not user_signed_in?
  end

  def check_for_invitation
    if session[:invitation_token]
      redirect_to invitation_path(session[:invitation_token])
    end
  end
end
