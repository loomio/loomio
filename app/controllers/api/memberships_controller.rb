class API::MembershipsController < API::RestfulController

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
