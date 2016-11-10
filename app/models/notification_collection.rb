class NotificationCollection
  attr_accessor :notifications

  def initialize(user, limit: 30)
    @notifications = user.notifications.includes(:actor, :event).order(created_at: :desc).limit(limit)

    # account for old notifications which don't have the url and translation_values fields populated.
    NotificationBaker.bake!(@notifications)
  end

  def serialize!(scope = {})
    ActiveModel::ArraySerializer.new(@notifications,
      scope:           scope,
      each_serializer: NotificationSerializer,
      root:            :notifications
    ).as_json
  end
end
