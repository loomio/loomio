class API::InvitationsController < API::RestfulController
  def create
    load_and_authorize :group, :invite_people
    @invitations = InvitationService.invite_to_group(recipient_emails: email_addresses,
                                                     group: @group,
                                                     inviter: current_user,
                                                     message: params[:message])
    respond_with_collection
  end

  def pending
    load_and_authorize :group, :view_pending_invitations
    @invitations = page_collection(@group.invitations.pending)
    respond_with_collection
  end

  def shareable
    load_and_authorize :group, :view_shareable_invitation
    @invitations = [InvitationService.shareable_invitation_for(@group)]
    respond_with_collection
  end

  def destroy
    @invitation = Invitation.find(params[:id])
    InvitationService.cancel(invitation: @invitation, actor: current_user)
    respond_with_resource
  end

  private
  def email_addresses
    params[:email_addresses].scan(/[^\s<,]+?@[^>,\s]+/).take(100)
  end

  def new_members
    common_params.merge users: invitation_parser.new_members
  end

  def new_emails
    common_params.merge recipient_emails: invitation_parser.new_emails
  end

  def common_params
    @common_params ||= { group: @group, inviter: current_user, message: params[:message] }
  end

  def invitation_parser
    @invitation_parser ||= InvitationParser.new(@invitations)
  end

end
