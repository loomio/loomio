class Groups::GroupSetupController < BaseController

  def setup
    @group_setup = GroupSetup.find_or_create_by_group_id(params[:id])
  end

  def finish
    @group_setup = GroupSetup.find_by_group_id(params[:id])
    @group_setup.update_attributes(params[:group_setup])
    if @group_setup.finish!(current_user)
      # invite_attributes = build_invite_attributes(params[:group_setup])
      # invite_people = InvitePeople.new(invite_attibutes)
      # num = CreateInvitation.to_people_and_email_them(invite_people, group: @group_setup.group, inviter: current_user)
      flash[:notice] = "#{num} invitations sent"
      render '/group_setup/finished'
    else
      render '/group_setup/setup'
    end
  end

  private

  def build_invite_attributes(attrs)
    { recipients: attrs[:members_list],
      message_body: ( attrs[:invite_body] + attrs[:invite_body_uneditable] )}
  end
end