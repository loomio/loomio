class API::MembershipsController < API::RestfulController
  load_resource only: [:set_volume, :make_admin, :remove_admin, :save_experience]

  def add_to_subgroup
    self.collection = service.add_users_to_group(users: @group.parent.members.where(id: required_param(:user_ids)),
                                                 group: @group,
                                                 inviter: current_user)
    respond_with_collection
  end

  def index
    instantiate_collection { |collection| collection.active.where(group: load_and_authorize(:group)).order('users.name') }
    respond_with_collection
  end

  def for_user
    instantiate_collection { |collection| collection.where(user: load_and_authorize(:user)).order('groups.full_name') }
    respond_with_collection
  end

  def join_group
    @event = service.join_group group: load_and_authorize(:group), actor: current_user
    respond_with_resource
  end

  def invitables
    self.collection = page_collection visible_invitables
    respond_with_collection scope: { q: required_param(:q), include_inviter: false }
  end

  def my_memberships
    self.collection = current_user.memberships.includes(:user, :inviter)
    respond_with_collection
  end

  def autocomplete
    self.collection = visible_autocompletes
    respond_with_collection
  end

  def make_admin
    service.make_admin membership: resource, actor: current_user
    respond_with_resource
  end

  def remove_admin
    service.remove_admin membership: resource, actor: current_user
    respond_with_resource
  end

  def set_volume
    service.set_volume membership: resource, params: params.slice(:volume, :apply_to_all), actor: current_user
    respond_with_resource
  end

  def save_experience
    service.save_experience membership: resource, actor: current_user, params: { experience: required_param(:experience) }
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

  def visible_autocompletes
    Queries::VisibleAutocompletes.new(query: required_param(:q),
                                      group: load_and_authorize(:group, :members_autocomplete),
                                      current_user: current_user,
                                      limit: 10)
  end

  def visible_invitables
    Queries::VisibleInvitableMemberships.new(query: required_param(:q),
                                             group: load_and_authorize(:group, :invite_people),
                                             user: current_user)
  end
end
