class API::InvitationsController < API::RestfulController

  def create
    load_and_authorize :group, :invite_people
    @invitations = params[:invitations]
    
    MembershipService.add_users_to_group new_members
    InvitationService.invite_to_group    new_emails

    respond_with_collection
  end

  private

  def new_members
    common_params.merge users: invitation_parser.new_members
  end

  def new_emails
    common_params.merge recipient_emails: invitation_parser.new_emails
  end

  def common_params
    @common_params ||= { group: @group, inviter: current_user, message: params[:invite_message] }
  end

  def invitation_parser
    @invitation_parser ||= InvitationParser.new(@invitations)
  end

end
