class API::GroupsController < API::RestfulController
  load_and_authorize_resource only: :show, find_by: :key

  def show
    respond_with_resource
  end

  def archive
    GroupService.archive(actor: current_user, params: params)
    respond_with_resource
  end

  def subgroups
    load_and_authorize :group
    @groups = @group.subgroups.select{|g| can? :show, g }
    respond_with_collection
  end

end
