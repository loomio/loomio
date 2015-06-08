class API::InvitablesController < API::RestfulController

  private

  def visible_records
    load_and_authorize :group, :invite_people
    Queries::VisibleInvitableUsers.new(
      query: params[:q],
      group: @group,
      user:  current_user,
      limit: 5)
  end

  def resource_class
    User
  end

  def default_page_size
    5
  end

  def serializer_root
    :users
  end

end
