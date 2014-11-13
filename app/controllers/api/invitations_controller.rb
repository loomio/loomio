class API::InvitationsController < API::RestfulController

  def create
    @group = Group.find(params[:group_id])
    authorize! :invite_people, @group

    parse_invitations

    MembershipService.add_users_to_group membership_params
    InvitationService.invite_to_group    invitation_params

    respond_with_collection
  end

  private

  def parse_invitations
    @user_ids, @contact_ids = [],[]
    params[:invitations].each do |invitation|
      case invitation[:type]
      when 'User'    then @user_ids    << invitation[:id]
      when 'Group'   then @user_ids    << Group.find(invitation[:id]).members.pluck(:id)
      when 'Contact' then @contact_ids << invitation[:id]
      end
    end
  end

  def membership_params
    @membership_params ||= common_params.merge users: User.find(@user_ids.flatten)
  end

  def invitation_params
    @invitation_params ||= common_params.merge recipient_emails: Contact.find(@contact_ids).map(&:email)
  end

  def common_params
    @common_params ||= { group: @group, inviter: current_user, message: params[:invite_message] }
  end

end
