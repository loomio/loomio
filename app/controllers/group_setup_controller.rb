class GroupSetupController < BaseController

  def setup
    @group_setup = GroupSetup.find_or_create_by_group_id(params[:id])
  end

  def finish
    @group_setup = GroupSetup.find_by_group_id(params[:id])
    @group_setup.compose_group
    @group_setup.compose_discussion
    @group_setup.compose_motion
    @group_setup.save!
    @group_setup.send_invitations
    redirect_to group_path(@group_setup.group_id)
  end
end