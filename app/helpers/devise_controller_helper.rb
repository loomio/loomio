module DeviseControllerHelper
  include AutodetectTimeZone
  include OmniauthAuthenticationHelper

  protected

  def after_sign_in_path_for(user)
    return super(user) unless sign_up_group

    sign_up_group.tap do |group|
      user.ability.authorize! :join, group
      group.add_member!(user)
      session.delete(:invitation_token) if invitation_from_session
      session.delete(:group_key)        if group_from_session
    end
  end

  private

  def sign_up_group
    group_from_session || invitation_from_session&.group
  end

  def group_from_session
    return unless session[:group_key]
    @group_from_session ||= Group.find_by(key: session[:group_key])
  end

  def invitation_from_session
    return unless session[:invitation_token]
    @invitation_from_session ||= Invitation.find_by(token: session[:invitation_token])
  end
end
