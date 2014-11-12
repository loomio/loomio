class API::InvitationsController < API::RestfulController

  def create
    @group = Group.find(params[:group_id])
    authorize! :invite_people, @group

    @invitations = params[:invitations]

    MembershipService.add_users_to_group membership_params
    InvitationService.invite_to_group    invitation_params

    Measurement.measure 'invitations.invite_members',    members_to_add.size
    Measurement.measure 'invitations.invite_new_emails', emails_to_invite.size

    respond_with_collection
  end

  private

  def membership_params
    @membership_params ||= common_params.merge users: members_to_add
  end
  def invitation_params
    @invitation_params ||= common_params.merge recipient_emails: emails_to_invite
  end

  def common_params
    @common_params ||= { group: @group, inviter: current_user, message: params[:invite_message] }
  end

  def members_to_add
    @members_to_add ||= User.where id: @invitations.map { |i| i[:user_id] }.compact
  end

  def emails_to_invite
    @emails_to_invite ||= @invitations.map { |i| i[:recipients] }.compact.flatten
  end

end
