class API::V1::MembershipsController < API::V1::RestfulController
  load_resource only: [:set_volume]

  def index
    instantiate_collection do |collection|
      %w[user_xids].each do |key|
        next unless params.has_key? key
        params[key.gsub("_xids", "_ids")] = params[key].split('x').map(&:to_i)
        params.delete(key)
      end
      MembershipQuery.search(chain: collection, params: params).order('memberships.group_id, memberships.admin desc, memberships.created_at desc')
    end
    respond_with_collection(scope: index_scope)
  end

  def destroy_response
    render json: Array(resource.group), each_serializer: GroupSerializer, root: :groups, scope: {}
  end

  # move to profile controller later
  def for_user
    load_and_authorize :user
    same_group_ids   = current_user.group_ids & @user.group_ids
    public_group_ids = @user.groups.visible_to_public.pluck(:id)
    instantiate_collection do |collection|
      Membership.joins(:group).where(group_id: same_group_ids + public_group_ids, user_id: @user.id).active.order('groups.full_name')
    end
    respond_with_collection serializer: MembershipSerializer
  end

  def join_group
    event = service.join_group group: load_and_authorize(:group), actor: current_user
    @membership = event.eventable
    respond_with_resource
  end

  def my_memberships
    @memberships = current_user.memberships.includes(:user, :inviter)
    respond_with_collection
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

  private
  def valid_orders
    ['memberships.created_at', 'memberships.created_at desc', 'users.name', 'admin desc', 'accepted_at desc', 'accepted_at']
  end

  def index_scope
    default_scope.merge({ include_email: model.admins.exists?(current_user.id), include_inviter: true })
  end

  def model
    load_and_authorize(:group, :see_private_content, optional: true) ||
    load_and_authorize(:discussion, optional: true) ||
    load_and_authorize(:poll, optional: true) ||
    NullGroup.new
  end

  def accessible_records
    MembershipQuery.visible_to(user: current_user)
  end
end
