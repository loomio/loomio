class API::InvitationsController < API::RestfulController

  def create
    @group = Group.find(params[:group_id])
    authorize! :invite_people, @group

    @invitations = params[:invitations]

    MembershipService.add_users_to_group membership_params
    InvitationService.invite_to_group    invitation_params

    Measurement.measure 'invitations.invite_members',    members_emails.size
    Measurement.measure 'invitations.invite_new_emails', non_member_emails.size

    respond_with_collection
  end

  private

  def membership_params
    @membership_params ||= common_params.merge users: User.where(email: members_emails)
  end
  def invitation_params
    @invitation_params ||= common_params.merge recipient_emails: non_member_emails
  end

  def common_params
    @common_params ||= { group: @group, inviter: current_user, message: params[:invite_message] }
  end

  def members_emails
    @invitations.select { |i| i[:is_loomio_member] }.map { |i| i[:recipients] }.flatten.compact
  end

  def non_member_emails
    @invitations.reject { |i| i[:is_loomio_member] }.map { |i| i[:recipients] }.flatten.compact
  end

end
