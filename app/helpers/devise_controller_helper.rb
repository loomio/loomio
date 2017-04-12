module DeviseControllerHelper
  include OmniauthAuthenticationHelper

  protected

  def after_sign_in_path_for(user)
    if invitation = invitation_from_session
      session.delete(:invitation_token)
      invitation
    elsif group = group_from_session
      session.delete(:group_key)
      MembershipService.join_group(actor: user, group: group)
      group
    else
      super(user)
    end
  end

  private

  def group_from_session
    Group.find_by(key: session[:group_key]) if session[:group_key]
  end

  def invitation_from_session
    Invitation.find_by(token: session[:invitation_token]) if session[:invitation_token]
  end
end
