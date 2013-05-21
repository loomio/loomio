class Groups::GroupSetupController < GroupBaseController
  before_filter :permitted_to_setup, :already_setup, only: :setup

  def setup
    @group_setup = GroupSetup.find_or_create_by_group_id(params[:id])
    @group = Group.find(params[:id])
    @group_setup.group_name ||= @group.name
  end

  def finish
    @group_setup = GroupSetup.find_by_group_id(params[:id])
    @group_setup.update_attributes(params[:group_setup])
    @group_setup.admin_email = current_user.email
    if @group_setup.finish!(current_user)
      invite_attributes = build_invite_attributes(params[:group_setup])
      @invite_people = InvitePeople.new(invite_attributes)
      num = CreateInvitation.to_people_and_email_them(@invite_people, group: @group_setup.group, inviter: current_user)
      flash[:notice] = "#{num} invitation(s) sent"
      @group_setup.group.setup_completed_at = Time.now
      @group_setup.group.save!
      redirect_to group_path
    else
      render 'setup'
    end
  end

  private

  def permitted_to_setup
    @group = Group.find(params[:id])
    redirect_to error_path(message: t('error.not_permitted_to_setup_group')) unless current_user.is_group_admin?(@group)
  end

  def already_setup
    @group = Group.find(params[:id])
    redirect_to error_path(message: t('error.group_already_setup')) unless @group.setup_completed_at.nil?
  end

  def build_invite_attributes(attrs)
    { recipients: attrs[:recipients],
      message_body: ( attrs[:message_body] + t("invitation.body_uneditable",
                                              motion_title: attrs[:motion_title],
                                              motion_description: attrs[:motion_description],
                                              group: attrs[:group_name],
                                              user: current_user.name
                                              ))}
  end
end
