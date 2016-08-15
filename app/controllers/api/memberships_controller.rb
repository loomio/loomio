class Api::MembershipsController < Api::RestfulController

  def add_to_subgroup
    group = fetch_and_authorize(:group)
    users = group.parent.members.where('users.id': params[:user_ids])
    @memberships = MembershipService.add_users_to_group(users: users,
                                                        group: group,
                                                        inviter: current_user)
    respond_with_collection
  end

  def index
    fetch_and_authorize :group
    instantiate_collection { |collection| collection.active.where(group_id: @group.id).order('users.name') }
    respond_with_collection
  end

  def for_user
    fetch_and_authorize :user
    instantiate_collection { |collection| collection.where(user_id: @user.id).order('groups.full_name') }
    respond_with_collection
  end

  def join_group
    event = service.join_group group: fetch_resource(:group), actor: current_user
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
    @memberships = Queries::VisibleAutocompletes.new(query: params[:q],
                                                     group: fetch_and_authorize(:group, :members_autocomplete),
                                                     current_user: current_user,
                                                     limit: 10)
    respond_with_collection
  end

  def make_admin
    service.make_admin(membership: fetch_resource, actor: current_user)
    respond_with_resource
  end

  def remove_admin
    service.remove_admin(membership: fetch_resource, actor: current_user)
    respond_with_resource
  end

  def set_volume
    service.set_volume membership: fetch_resource, params: params.slice(:volume, :apply_to_all), actor: current_user
    respond_with_resource
  end

  def save_experience
    raise ActionController::ParameterMissing.new(:experience) unless params[:experience]
    service.save_experience membership: fetch_resource, actor: current_user, params: { experience: params[:experience] }
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
    Queries::VisibleInvitableMemberships.new(group: fetch_and_authorize(:group, :invite_people), user: current_user, query: params[:q])
  end
end
