class API::MembershipsController < API::RestfulController

  def index
    @group = Group.find(params[:group_id])
    authorize! :show, @group

    @memberships = Queries::VisibleMembers.new(group: @group, limit: 5)
    respond_with_collection
  end

  def autocomplete
    @group = Group.find(params[:group_id])
    authorize! :members_autocomplete, @group

    @memberships = Queries::VisibleAutocompletes.new(query: params[:q],
                                                     group: @group,
                                                     current_user: current_user,
                                                     limit: 5)
    respond_with_collection
  end

end
