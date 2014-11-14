class API::InvitablesController < API::RestfulController

  def index
    @group = Group.find(params[:group_id])
    authorize! :invite_people, @group

    @invitables = Queries::VisibleInvitables.new(query: params[:q],
                                                 group: @group,
                                                 user: current_user,
                                                 limit: 5)
    respond_with_collection each_serializer: InvitableSerializer
  end

end
