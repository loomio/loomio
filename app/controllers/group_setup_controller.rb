class GroupSetupController < BaseController

  def setup
    @group_setup = GroupSetup.find_or_create_by_id(params[:id])
    @group_id = params[:id]
    render 'setup'
  end
end