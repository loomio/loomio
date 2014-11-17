class API::InvitablesController < API::RestfulController

  def index
    @group = Group.find(params[:group_id])
    authorize! :invite_people, @group

    @invitables = Queries::VisibleInvitables.new(
                    query: params[:q],
                    group: @group,
                    user: current_user,
                    limit: 5).map { |invitable| serialization_for(invitable) }

    respond_with_collection
  end

  private

  def serialization_for(invitable)
    case invitable
    when Group   then Invitables::GroupSerializer
    when Contact then Invitables::ContactSerializer
    when User    then Invitables::UserSerializer
    else              Invitables::BaseSerializer
    end.new(invitable, root: false).as_json
  end

end
