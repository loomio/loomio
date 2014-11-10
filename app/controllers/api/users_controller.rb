class API::UsersController < API::RestfulController

  def members
    @group = Group.find(params[:group_id])
    authorize! :members_autocomplete, @group

    @users = visible_memberships(query: params[:q]).limit(5)
    respond_with_collection
  end

  private

  # replace me with a query!
  def visible_memberships(options = {})
    @group.members.active.where("name ilike '%#{options[:query]}%'").sorted_by_name
  end

end
