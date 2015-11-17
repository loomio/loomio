class API::MembershipsController < API::RestfulController

  def index
    load_and_authorize :group
    instantiate_collection { |collection| collection.where(group_id: @group.id).order('users.name') }
    respond_with_collection
  end

  def for_user
    load_and_authorize :user
    instantiate_collection { |collection| collection.where(user_id: @user.id).order('groups.full_name') }
    respond_with_collection
  end

  def join_group
    @group = Group.find(params[:group_id])
    event = MembershipService.join_group group: @group, actor: current_user
    @membership = event.eventable
    respond_with_resource
  end

  def invitables
    @memberships = page_collection visible_invitables
    respond_with_collection scope: { q: params[:q], include_inviter: false }
  end

  def my_memberships
    @memberships = current_user.memberships.includes(:user, :inviter)
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

  def accessible_records
    visible = resource_class.joins(:group).includes(:user, :inviter, {group: [:parent, :subscription]})
    if current_user.group_ids.any?
      visible.where("group_id IN (#{current_user.group_ids.join(',')}) OR groups.is_visible_to_public = 't'")
    else
      visible.where("groups.is_visible_to_public = 't'")
    end
  end

  def visible_invitables
    load_and_authorize :group, :invite_people
    Queries::VisibleInvitableMemberships.new(group: @group, user: current_user, query: params[:q])
  end
end
