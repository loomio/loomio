class BaseController < ApplicationController
  before_filter :authenticate_user!, :check_browser, :check_invitation, :load_announcements

  protected

  def store_location
    session[:return_to] = request.fullpath
  end

  def clear_stored_location
    session[:return_to] = nil
  end

  def after_sign_in_path_for(resource)
    path = session[:return_to] || root_path
    clear_stored_location
    path
  end

  def load_announcements
    if current_user
      @current_and_not_dismissed_announcements = Announcement.current_and_not_dismissed_by(current_user)
    end
  end

  def check_browser
    if browser.ie6? # || browser.ie7?
      redirect_to browser_not_supported_url
    end
  end

  def check_invitation
    if user_signed_in? && session[:start_new_group_token]
      group_request = GroupRequest.find_by_token(session[:start_new_group_token])
      if group_request && (not group_request.accepted?)
        group_request.accept!(current_user)
        flash[:success] = "You have been added to #{group_request.group.name}."
        session[:start_new_group_token] = nil
        redirect_to group_url(group_request.group_id)
      end
    end
  end
end
