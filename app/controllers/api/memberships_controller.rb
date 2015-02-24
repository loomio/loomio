class API::MembershipsController < API::RestfulController

  def create
    params[:group_id] = params[:membership][:group_id]
    load_and_authorize_group
    event = MembershipService.join_group group: @group, user: current_user
    @membership = event.eventable
    respond_with_resource
  end

  def my_memberships
    @memberships = current_user.memberships.joins(:group).order('groups.full_name ASC')
    respond_with_collection
  end

  def autocomplete
    load_and_authorize_group
    authorize! :members_autocomplete, @group

    @memberships = Queries::VisibleAutocompletes.new(query: params[:q],
                                                     group: @group,
                                                     current_user: current_user,
                                                     limit: 5)
    respond_with_collection
  end

  def make_admin
    load_resource
    MembershipService.make_admin(membership: @membership, actor: current_user)
    respond_with_resource
  end

  def remove_admin
    load_resource
    MembershipService.remove_admin(membership: @membership, actor: current_user)
    respond_with_resource
  end

  private

  def visible_records
    load_and_authorize_group
    Queries::VisibleMemberships.new(user: current_user, group: @group)
  end

  def default_page_size
    5
  end

end
