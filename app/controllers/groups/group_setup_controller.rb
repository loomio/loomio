class Groups::GroupSetupController < GroupBaseController

  def setup
    @group_setup = GroupSetup.find_or_create_by_group_id(params[:id])
    @group = Group.find(params[:id])
    render 'no_permission' unless current_user.is_group_admin?(@group)
    #render 'already_setup' unless @group.setup_completed_at.nil?
  end

  def finish
    @group_setup = GroupSetup.find_by_group_id(params[:id])
    @group_setup.update_attributes(params[:group_setup])
    @group_setup.admin_email = current_user.email
    if @group_setup.finish!(current_user)
      invite_attributes = build_invite_attributes(params[:group_setup])
      @invite_people = InvitePeople.new(invite_attributes)
      num = CreateInvitation.to_people_and_email_them(@invite_people, group: @group_setup.group, inviter: current_user)
      flash[:notice] = "#{num} invitations sent"
      @group_setup.group.setup_completed_at = Time.now
      @group_setup.group.save!
      render 'finished'
    else
      render 'setup'
    end
  end

  def save_setup
    @group_setup = GroupSetup.find_by_group_id(params[:id])
    @group_setup.update_attributes(params)
  end


  private

  def build_invite_attributes(attrs)
    { recipients: attrs[:recipients],
      message_body: ( attrs[:message_body] + t("invitation_to_join_group.body_uneditable",
                                              motion_title: attrs[:motion_title],
                                              motion_description: attrs[:motion_description],
                                              group: attrs[:group_name],
                                              user: current_user.name
                                              ))}
  end
end
