class BaseController < InheritedResources::Base
  before_filter :authenticate_user!, :check_browser, :check_invitation, :get_notifications
  # inherit_resources

  def check_browser
    if browser.ie6? # || browser.ie7?
      redirect_to browser_not_supported_url
    end
  end

  def check_invitation
    @invitation = Invitation.find_by_token(session[:invitation])
    if @invitation && user_signed_in?
      group = Group.find(@invitation.group_id)
      group.add_member!(current_user)
      @invitation.destroy!
      redirect_to group_path(group.id)
    end
  end

  def get_notifications
    if user_signed_in?
      @unviewed_notifications = current_user.unviewed_notifications
      @notifications = current_user.recent_notifications
    end
  end
end
