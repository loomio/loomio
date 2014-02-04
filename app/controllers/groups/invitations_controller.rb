class Groups::InvitationsController < GroupBaseController
  before_filter :require_current_user_can_invite_people
  before_filter :ensure_invitations_available, only: [:new, :create]

  def new
    @invite_people_form = InvitePeopleForm.new
    load_decorated_group
  end

  def create
    @invite_people_form = InvitePeopleForm.new(params[:invite_people_form])
    MembershipService.add_users_to_group(users: @invite_people_form.members_to_add,
                                         group: @group,
                                         inviter: current_user)


    CreateInvitation.to_people_and_email_them(recipient_emails: @invite_people_form.emails_to_invite,
                                              message: @invite_people_form.message_body,
                                              group: @group,
                                              inviter: current_user)

    set_flash_message
    redirect_to group_memberships_path(@group)
  end

  def index
    @pending_invitations = @group.pending_invitations
    load_decorated_group
  end

  def destroy
    load_invitation
    @invitation.cancel!(canceller: current_user)
    redirect_to group_memberships_path(@group), notice: "Invitation to #{@invitation.recipient_email} cancelled"
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
    group
  end

  def set_flash_message
    unless @invite_people_form.emails_to_invite.empty?
      invitations_sent = t(:'notice.invitations.sent', count: @invite_people_form.emails_to_invite.size)
    end

    unless @invite_people_form.members_to_add.empty?
      members_added = t(:'notice.invitations.auto_added', count: @invite_people_form.members_to_add.size)
    end

    # expected output: 6 people invitations sent, 10 people added to group
    message = [invitations_sent, members_added].compact.join(", ")
    flash[:notice] = message
  end
end
