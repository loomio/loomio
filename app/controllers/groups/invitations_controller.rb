class Groups::InvitationsController < GroupBaseController
  before_filter :require_current_user_can_invite_people
  before_filter :ensure_invitations_available, only: [:new, :create]

  def new
    @invite_people = InvitePeople.new
    load_decorated_group
  end

  def create
    @emails = params[:invite_people][:recipients].split(',')

    recognised_users = User.where(email: @emails)
    @members_to_add = recognised_users - @group.members.all
    @existing_members = recognised_users - @members_to_add
    @emails_to_invite = @emails - recognised_users.pluck(:email)

    @invite_people = InvitePeople.new(params[:invite_people])
    @invite_people.recipients = @emails_to_invite.join(',')

    memberships = @group.add_members!(@members_to_add, current_user)
    memberships.each do |membership|
      Events::UserAddedToGroup.publish!(membership)
      UserMailer.delay.added_to_a_group(membership.user, membership.inviter, membership.group)
    end

    if @invite_people.valid?
      CreateInvitation.to_people_and_email_them(@invite_people,
                                                  group: @group,
                                                  inviter: current_user)
    end
    set_invitation_success_flash
    redirect_to group_path(@group)
  end

  def index
    @pending_invitations = @group.pending_invitations
    load_decorated_group
  end

  def destroy
    load_invitation
    @invitation.cancel!(canceller: current_user)
    redirect_to group_invitations_path(@group), notice: "Invitation to #{@invitation.recipient_email} cancelled"
  end

  private

  def ensure_invitations_available
    unless @group.invitations_remaining > 0
      render 'no_invitations_left'
    end
  end

  def load_invitation
    @invitation = @group.pending_invitations.find(params[:id])
  end

  def load_decorated_group
    @group = GroupDecorator.new(Group.find(params[:group_id]))
  end

  def set_invitation_success_flash
    unless @emails_to_invite.empty?
      invitations_sent = t(:'notice.invitations.sent', count: @emails_to_invite.size)
    end

    unless @members_to_add.empty?
      members_added = t(:'notice.invitations.auto_added', count: @members_to_add.size)
    end

    unless @existing_members.empty?
      members_already_in_group = t(:'notice.invitations.existing_member', count: @existing_members.size)
    end

    # expected output: 6 people invitations sent, 10 people added to group, 1 member already in group
    message = [invitations_sent, members_added, members_already_in_group].compact.join(", ")
    flash[:notice] = message
  end
end
