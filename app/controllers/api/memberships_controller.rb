class API::MembershipsController < API::RestfulController

  def join_group
    @group = Group.find(params[:group_id])
    event = MembershipService.join_group group: @group, actor: current_user
    @membership = event.eventable
    respond_with_resource
  end

  def invitables
    @memberships = page_collection visible_invitables
    respond_with_collection scope: { q: params[:q] }
  end

  def my_memberships
    @memberships = current_user.memberships.includes(:group, :inviter)
    respond_with_collection
  end

  def autocomplete
    load_and_authorize :group
    authorize! :members_autocomplete, @group

    @memberships = Queries::VisibleAutocompletes.new(query: params[:q],
                                                     group: @group,
                                                     current_user: current_user,
                                                     limit: 10)
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
    load_and_authorize :group
    Queries::VisibleMemberships.new(user: current_user, group: @group)
  end

  def visible_invitables
    load_and_authorize :group, :invite_people
    Queries::VisibleInvitableMemberships.new(group: @group, user: current_user, query: params[:q])
  end

  def default_page_size
    5
  end

end
