module DeviseControllerHelper
  include AutodetectTimeZone
  include InvitationsHelper
  include OmniauthAuthenticationHelper

  protected

  def after_sign_in_path_for(user)
    return super(user) unless sign_up_group

    user.ability.authorize!(:join, sign_up_group)
    sign_up_group.tap do |group|
      user.ability.authorize! :join, group
      group.add_member!(user)
      clear_invitation_token_from_session if invitation_from_session
      clear_group_key_from_session        if group_from_session
    end
  end

  private

  def sign_up_group
    group_from_session || invitation_from_session&.group
  end

  def group_from_session
    @group_from_session ||= Group.find_by(key: session[:group_key]) if session[:group_key]
  end

  def clear_group_key_from_session
    session.delete(:group_key)
  end

  def invitation_from_session
    @invitation_from_session ||= load_invitation_from_session
  end
end
