class API::GroupsController < API::RestfulController
  load_and_authorize_resource only: :show, find_by: :key

  def show
    respond_with_resource
  end

  def subgroups
    @group = Group.find(params[:parent_id])
    authorize! :show, @group

    @groups = @group.subgroups.select{|g| can? :show, g }
    respond_with_collection
  end

end
