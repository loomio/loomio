class API::UsersController < API::RestfulController

  def invitables
    load_and_authorize :group, :invite_people
    @users = visible_invitables
    respond_with_collection
  end

  private

  def visible_invitables
    Queries::VisibleInvitableUsers.new(
      query: params[:q],
      group: @group,
      user: current_user)
  end

end
