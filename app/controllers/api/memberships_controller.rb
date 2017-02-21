class API::MembershipsController < API::RestfulController
  load_resource only: [:set_volume]

  def add_to_subgroup
    group = load_and_authorize(:group)
    users = group.parent.members.where('users.id': params[:user_ids])
    @memberships = MembershipService.add_users_to_group(users: users,
                                                        group: group,
                                                        inviter: current_user)
    respond_with_collection
  end

  def index
    load_and_authorize :group
    instantiate_collection { |collection| collection.active.where(group_id: @group.id).order('users.name') }
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

  def set_volume
    service.set_volume membership: resource, params: params.slice(:volume, :apply_to_all), actor: current_user
    respond_with_resource
  end

  def save_experience
    raise ActionController::ParameterMissing.new(:experience) unless params[:experience]
    service.save_experience membership: load_resource, actor: current_user, params: { experience: params[:experience] }
    respond_with_resource
  end

  def undecided
    load_and_authorize(:poll)
    instantiate_collection do |collection|
      collection = collection.where(group: @poll.group)
      collection = collection.where("memberships.user_id NOT IN (?)", @poll.participant_ids) if @poll.participant_ids.present?
      collection
    end
    respond_with_collection
  end

  private

  def accessible_records
    visible = resource_class.joins(:group).includes(:user, :inviter, {group: [:parent]})
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
