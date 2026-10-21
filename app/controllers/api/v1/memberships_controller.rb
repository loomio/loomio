class Api::V1::MembershipsController < Api::V1::RestfulController
  load_resource only: [:set_volume]
  before_action :require_current_user, only: [ :notification_history ]

  def index
    model
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
    public_group_ids = @user.groups.where(listed_in_explore: true).pluck(:id)
    instantiate_collection do |collection|
      Membership.joins(:group).where(group_id: same_group_ids + public_group_ids, user_id: @user.id).active.order('groups.full_name')
    end
    respond_with_collection serializer: MembershipSerializer
  end

  def join_group
    @membership = service.join_group group: load_and_authorize(:group), actor: current_user
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

  def notification_history
    # Batch invitation records contain other recipients. Project only this
    # membership's deliveries and recorded feedback after coordinator checks.
    membership = load_resource
    current_user.ability.authorize! :notification_history, membership
    notifications = page_collection_bounded(MembershipNotificationHistory.for(membership)).to_a
    deliveries = NotificationDelivery.where(notification_id: notifications.map(&:id),
      recipient_type: 'User', recipient_id: membership.user_id).includes(:events).group_by(&:notification_id)
    actors = User.where(id: notifications.map(&:actor_id)).index_by(&:id)

    rows = notifications.map do |notification|
      email = Array(deliveries[notification.id]).find { |delivery| delivery.channel == 'email' }
      {
        id: notification.id,
        kind: notification.kind,
        created_at: notification.created_at,
        sender_name: actors[notification.actor_id]&.name_or_username,
        message: notification.recipient_message,
        email_subject: email&.email_subject,
        email_sent_at: email&.delivered_at,
        email_status: email ? email.email_status :
          (notification.deliveries_generated_at ? 'not_sent' : 'pending'),
        email_events: email ? email.events.sort_by { |event| [ event.occurred_at, event.id ] }.map { |event|
          { id: event.id, kind: event.kind, occurred_at: event.occurred_at, detail: event.detail }
        } : []
      }
    end
    render json: { history: rows }
  end

  def make_admin
    service.make_admin(membership: load_resource, actor: current_user)
    respond_with_resource
  end

  def remove_admin
    service.remove_admin(membership: load_resource, actor: current_user)
    respond_with_resource
  end

  def make_delegate
    service.make_delegate(membership: load_resource, actor: current_user)
    respond_with_resource
  end

  def remove_delegate
    service.remove_delegate(membership: load_resource, actor: current_user)
    respond_with_resource
  end

  def set_volume
    service.set_volume(
      membership: resource,
      params: params.slice(:volume_email, :volume_push, :apply_to_all),
      actor: current_user
    )
    respond_with_resource
  end

  def set_weights
    service.set_weights(
      group: Group.find(params.require(:group_id)),
      weights_by_membership_id: params.require(:weights).to_unsafe_h,
      actor: current_user
    )
    render json: {updated: true}
  end

  # Large groups page and search the weight editor on the server. Order by name
  # with the membership id as a tiebreak so offsets stay stable.
  def weights
    group = Group.find(params.require(:group_id))
    current_user.ability.authorize! :set_weight, Membership.new(group: group)
    memberships = group.memberships.active.joins(:user)
    memberships = memberships.merge(User.invitable_search(params[:q])) if params[:q].present?
    total = memberships.count
    rows = page_collection_bounded(memberships.includes(user: {uploaded_avatar_attachment: :blob})
      .order('users.name, memberships.id')).map do |membership|
        user = membership.user
        {
          id: membership.id,
          user_id: user.id,
          name: user.name.presence || user.email,
          email: user.email,
          avatar_url: user.thumb_url,
          avatar_initials: user.avatar_initials,
          title: membership.title,
          delegate: membership.delegate,
          weight: VoteWeight.format(membership.weight)
        }
      end
    render json: {memberships: rows, total:}
  end

  def reset_weights
    service.reset_weights(group: Group.find(params.require(:group_id)), weight: params.require(:weight), actor: current_user)
    render json: {updated: true}
  end

  def save_experience
    raise ActionController::ParameterMissing.new(:experience) unless params[:experience]
    service.save_experience membership: load_resource, actor: current_user, params: { experience: params[:experience] }
    respond_with_resource
  end

  def user_name
    user = User.active.find(params[:id])
    if (user.name.blank? || !user.email_verified) &&
       (user.group_ids & current_user.adminable_group_ids).length > 0
      user.update(name: params[:name])
      self.resource = user
      respond_with_resource
    else
      error_response(403)
    end
  end

  private
  def destroy_action
    service.revoke(**{resource_symbol => resource, actor: current_user})
  end

  def valid_orders
    ['memberships.created_at', 'memberships.created_at desc', 'users.name', 'admin desc', 'accepted_at desc', 'accepted_at']
  end

  def index_scope
    default_scope.merge({
      membership_email_group_ids: current_user.adminable_group_ids,
      include_inviter: true,
      include_email_delivery_status: current_user.is_admin?
    })
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
