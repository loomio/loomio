class InvitationForm

  def initialize(group:, user:, message:, invitations:)
    @group, @user, @message, @invitations = group, user, message, invitations
  end

  def new_emails
    common_params.merge recipient_emails: new_email_invitations
  end

  def new_members
    common_params.merge users: new_member_invitations
  end

  private

  def new_email_invitations
    @new_emails ||= invitations_by_type(:email, :email) + 
                    invitations_by_type(:contact, :email)
  end

  def new_member_invitations
    @new_members ||= invitations_by_type(:user, :id) + 
                     Membership.where(group_id: invitations_by_type(:group, :id).pluck(:user_id))
  end

  def invitations_by_type(type, field)
    @invitations.select { |invitation| invitation.type == type.to_s }
                .map    { |invitation| invitation[field.to_s] }
  end

  def common_params
    @common_params ||= { group: @group, inviter: current_user, message: params[:invite_message] }
  end

end