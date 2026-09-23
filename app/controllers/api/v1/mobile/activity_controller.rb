class Api::V1::Mobile::ActivityController < Api::V1::Mobile::BaseController
  DEFAULT_LIMIT = 30
  MAX_LIMIT = 50

  before_action -> { require_mobile_scope!("activity:read") }, only: :index
  before_action -> { require_mobile_scope!("activity:write") }, only: :update

  def index
    candidates = accessible_records.limit(limit + 1).to_a
    page = candidates.first(limit)
    visible = NotificationQuery.currently_accessible_to(
      user: current_user,
      notifications: page
    )

    no_store!
    render json: {
      activity: visible.map { |notification| serialize(notification) },
      next_before_id: candidates.length > limit ? page.last.id : nil
    }
  end

  def update
    notification = accessible_records.find_by(id: params[:id])
    unless notification && NotificationQuery.currently_accessible_to(
      user: current_user,
      notifications: [ notification ]
    ).any?
      raise ActiveRecord::RecordNotFound
    end

    NotificationDelivery.delivered.where(
      notification: notification,
      recipient: current_user,
      channel: "in_app",
      viewed_at: nil
    ).update_all(viewed_at: Time.current, updated_at: Time.current)

    no_store!
    render json: { id: notification.id, viewed: true }
  end

  private

  def current_user
    current_mobile_device.user
  end

  def accessible_records
    records = NotificationQuery.delivered_to(user: current_user)
      .includes(:actor, :subject, :notification_deliveries)
      .order(id: :desc)
    before_id ? records.where("notifications.id < ?", before_id) : records
  end

  def limit
    @limit ||= bounded_integer_parameter(:limit, default: DEFAULT_LIMIT, maximum: MAX_LIMIT)
  end

  def before_id
    return @before_id if defined?(@before_id)

    @before_id = params[:before_id].present? ? bounded_integer_parameter(:before_id) : nil
  end

  def bounded_integer_parameter(name, default: nil, maximum: nil)
    raw = params[name]
    return default if raw.blank? && default
    raise Mobile::AuthenticationService::Error.new("invalid_request") unless raw.to_s.match?(/\A[1-9]\d*\z/)

    value = Integer(raw, 10)
    raise Mobile::AuthenticationService::Error.new("invalid_request") if maximum && value > maximum

    value
  end

  def serialize(notification)
    values = notification.translation_values_for(current_user.id)
    {
      id: notification.id,
      kind: notification.kind,
      title: values["title"].to_s.presence,
      name: values["name"].to_s.presence,
      actor_name: notification.actor&.name,
      url: notification.notification_url,
      created_at: notification.created_at,
      viewed: notification.viewed_for?(current_user.id)
    }
  end

  def no_store!
    response.headers["Cache-Control"] = "no-store"
    response.headers["Pragma"] = "no-cache"
  end
end
