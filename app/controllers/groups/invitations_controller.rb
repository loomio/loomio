class Groups::InvitationsController < GroupBaseController
  before_filter :require_current_user_is_group_admin

  def new
    @invite_people = InvitePeople.new
    @group = GroupDecorator.new(Group.find(params[:group_id]))
  end

  def create
    @invite_people = InvitePeople.new(params[:invite_people])
    num = CreateInvitation.to_people_and_email_them(@invite_people, group: @group, inviter: current_user)
    flash[:notice] = "#{num} invitation(s) sent" if num > 0
    redirect_to group_path(@group)
  end

  def index
    @pending_invitations = @group.pending_invitations
    @group = GroupDecorator.new(Group.find(params[:group_id]))
  end

  def destroy
    @invitation = @group.pending_invitations.find(params[:id])
    @invitation.destroy
    redirect_to group_invitations_path(@group), notice: "Invitation to #{@invitation.recipient_email} cancelled"

  end
end
