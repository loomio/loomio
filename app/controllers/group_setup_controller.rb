class GroupSetupController < BaseController

  def setup
    @group_setup = GroupSetup.find_or_create_by_group_id(params[:id])
  end

  def finish
    @group_setup = GroupSetup.find_by_group_id(params[:id])
    @group_setup.update_attributes(params[:group_setup])
    if @group_setup.finish!(current_user)
      @group_setup.send_invitations
      render 'finished'
    end
  end
end