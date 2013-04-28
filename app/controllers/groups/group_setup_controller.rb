class Groups::GroupSetupController < BaseController

  def setup
    @group_setup = GroupSetup.find_or_create_by_group_id(params[:id])
  end

  def finish
    @group_setup = GroupSetup.find_by_group_id(params[:id])
    @group_setup.update_attributes(params[:group_setup])
    if @group_setup.finish!(current_user)
      num = @group_setup.send_invitations
      flash[:notice] = "#{num} invitations sent"
      render '/group_setup/finished'
    else
      render '/group_setup/setup'
    end
  end
end