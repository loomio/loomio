class NotificationCollection
  attr_accessor :notifications

  def initialize(user, limit: 30)
    @notifications = user.notifications
                         .includes(:actor)
                         .order(created_at: :desc)
                         .limit(limit)
  end

  def serialize!(scope = {})
    ActiveModel::ArraySerializer.new(@notifications,
      scope:           scope,
      each_serializer: NotificationSerializer,
      root:            :notifications
    ).as_json
  end
end
