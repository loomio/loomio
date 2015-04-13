class API::InvitationsController < API::RestfulController

  def create
    @group = Group.find(params[:group_id])
    authorize! :invite_people, @group

    @invitations = parse_invitations

    MembershipService.add_users_to_group membership_params
    InvitationService.invite_to_group    invitation_params

    respond_with_collection
  end

  private

  def parse_invitations
    @user_ids, @contact_ids, @new_emails = [],[],[]
    Array(params[:invitations]).each do |invitation|
      case invitation[:type]
      when 'User'    then @user_ids    << invitation[:id]
      when 'Group'   then @user_ids    << Group.find(invitation[:id]).members.pluck(:id)
      when 'Contact' then @contact_ids << invitation[:id]
      when 'Email'   then @new_emails  << invitation[:email]
      end
    end
  end

  def membership_params
    @membership_params ||= common_params.merge users: new_members
  end

  def invitation_params
    @invitation_params ||= common_params.merge recipient_emails: new_invitations
  end

  def common_params
    @common_params ||= { group: @group, inviter: current_user, message: params[:invite_message] }
  end

  def new_members
    User.find(@user_ids.flatten)
  end

  def new_invitations
    Contact.where(id: @contact_ids).pluck(:email) + @new_emails
  end

end
