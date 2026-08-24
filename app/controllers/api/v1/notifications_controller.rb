class Api::V1::NotificationsController < Api::V1::RestfulController
  def index
    notifications = accessible_records.limit(50).to_a

    topic_ids = notifications.filter_map do |notification|
      subject = notification.subject_model
      subject.topic&.id if subject.respond_to?(:topic)
    end.uniq
    accessible_topic_ids = TopicQuery.visible_to(user: current_user)
                                     .unscope(:includes)
                                     .where(id: topic_ids)
                                     .pluck(:id)
                                     .to_set

    self.collection = notifications.select do |notification|
      subject = notification.subject_model
      topic_id = subject.respond_to?(:topic) ? subject.topic&.id : nil
      next false if topic_id && !accessible_topic_ids.include?(topic_id)

      current_user.can?(:show, subject)
    end
    respond_with_collection
  end

  def viewed
    service.viewed(user: current_user)
    render json: { success: :ok }
  end

  def accessible_records
    notification_ids = NotificationDelivery.where(
      recipient: current_user,
      channel: "in_app",
      status: "delivered"
    ).select(:notification_id)

    Notification
      .where(id: notification_ids)
      .includes(:actor, :subject, :notification_deliveries)
      .order(id: :desc)
  end
end
