class API::GroupsController < API::RestfulController
  load_and_authorize_resource only: :show, find_by: :key

  def show
    respond_with_resource
  end

  def archive
    load_resource
    GroupService.archive(group: @group, actor: current_user)
    respond_with_resource
  end

  def subgroups
    load_and_authorize_group
    @groups = @group.subgroups.select{|g| can? :show, g }
    respond_with_collection
  end

  def for_subdomain
    @group = resource_class.find_by_subdomain(params[:subdomain])
    respond_with_resource
  end

end
