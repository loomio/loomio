class API::MembershipsController < API::RestfulController
  load_resource only: [:set_volume]

  def add_to_subgroup
    group = load_and_authorize(:group)
    users = group.parent.members.where('users.id': params[:user_ids])
    @memberships = service.add_users_to_group(users: users,
                                              group: group,
                                              inviter: current_user)
    respond_with_collection
  end

  def index
    instantiate_collection do |collection|
      if params[:pending]
        collection.pending
      else
        collection.active
      end.where(group: model.groups).order('admin desc, created_at desc')
    end
    respond_with_collection(scope: index_scope)
  end

  def destroy_response
    render json: Array(resource.group), each_serializer: GroupSerializer, root: :groups
  end

  def for_user
    load_and_authorize :user
    same_group_ids   = current_user.formal_group_ids & @user.formal_group_ids
    public_group_ids = @user.formal_groups.visible_to_public.pluck(:id)
    instantiate_collection do |collection|
      Membership.joins(:group).where(group_id: same_group_ids + public_group_ids, user_id: @user.id).active.formal.order('groups.full_name')
    end
    respond_with_collection serializer: MembershipSerializer
  end

  def join_group
    event = service.join_group group: load_and_authorize(:group), actor: current_user
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
    instantiate_collection do |collection|
      group_ids = case params[:subgroups]
        when 'mine', 'all'
          model.group.id_and_subgroup_ids
        else
          model.groups
        end

      collection = collection.where(group_id: group_ids)

      collection = collection.active unless params.has_key?(:pending) #leave alone until 1.0 retired

      case params[:filter]
      when 'admin'
        collection = collection.admin
      when 'pending'
        collection = collection.pending
      end

      query = params[:q].to_s
      if query.length > 0
        collection = collection.joins(:user)
                               .where("users.name ilike :first OR
                                       users.name ilike :last OR
                                       users.username ilike :first",
                                       first: "#{query}%", last: "% #{query}%")
      end
      collection
    end
    respond_with_collection(scope: index_scope)
  end

  def resend
    service.resend membership: load_resource, actor: current_user
    respond_with_resource
  end

  def make_admin
    service.make_admin(membership: load_resource, actor: current_user)
    respond_with_resource
  end

  def remove_admin
    service.remove_admin(membership: load_resource, actor: current_user)
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
    poll = load_and_authorize(:poll)
    instantiate_collection { |collection| collection.where(group: poll.groups, user: poll.undecided) }
    respond_with_collection
  end

  private
  def valid_orders
    ['created_at', 'created_at desc', 'users.name', 'admin desc', 'accepted_at desc', 'accepted_at']
  end


  def index_scope
    { email_user_ids: collection.select { |m| m.inviter_id == current_user.id }.map(&:user_id), include_inviter: true }
  end

  def model
    load_and_authorize(:group, :see_private_content, optional: true) ||
    load_and_authorize(:discussion, optional: true) ||
    load_and_authorize(:poll, optional: true)
  end

  def accessible_records
    visible = resource_class.joins(:group).joins(:user).includes(:inviter, {group: [:parent]})
    if current_user.group_ids.any?
      visible.where("group_id IN (#{current_user.group_ids.join(',')}) OR
                     groups.parent_id IN (#{ids_or_null(current_user.adminable_group_ids)}) OR
                     groups.is_visible_to_public = 't'")
    else
      # why do we do this?
      visible.where("groups.is_visible_to_public = 't'")
    end
  end

  def ids_or_null(ids)
    if ids.length == 0
      'null'
    else
      ids.join(',')
    end
  end
  def visible_invitables
    load_and_authorize :group, :invite_people
    Queries::VisibleInvitableMemberships.new(group: @group, user: current_user, query: params[:q])
  end
end
