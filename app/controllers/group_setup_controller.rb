class GroupSetupController < BaseController

  def setup
    @group_setup = GroupSetup.find_or_create_by_id(params[:id])
    @group_id = params[:id]
    render 'setup'
  end

  def save
    @group_setup = GroupSetup.find(params[:id])
    @group_setup.save!
    render 'setup'
  end
end