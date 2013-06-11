class Groups::InvitationsController < GroupBaseController
  before_filter :require_current_user_can_invite_people
  before_filter :ensure_invitations_available, only: [:new, :create]

  def new
    @invite_people = InvitePeople.new
    load_decorated_group
  end

  def create
    @invite_people = InvitePeople.new(params[:invite_people])
    if @invite_people.valid?
      num = CreateInvitation.to_people_and_email_them(@invite_people, group: @group, inviter: current_user)
      flash[:notice] = "#{num} invitation(s) sent" if num > 0
      redirect_to group_path(@group)
    else
      load_decorated_group
      render :new
    end
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
end
