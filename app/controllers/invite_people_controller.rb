class InvitePeopleController < BaseController
  before_filter :load_group
  def new
    @invite_people = InvitePeople.new
  end

  def create
    @invite_people = InvitePeople.new(params[:invite_people])
    CreateInvitation.to_people_and_email_them(@invite_people, group: @group, inviter: current_user)
    redirect_to group_path(@group)
  end

  private
  def load_group
    @group = Group.find(params[:id])
  end
end
