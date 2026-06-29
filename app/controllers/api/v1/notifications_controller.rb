class Api::V1::NotificationsController < Api::V1::RestfulController
  def index
    notifications = accessible_records.limit(50).to_a

    topic_ids = notifications.map { |n| n.event&.topic_id }.compact.uniq
    accessible_topic_ids = TopicQuery.visible_to(user: current_user)
                                     .unscope(:includes)
                                     .where(id: topic_ids)
                                     .pluck(:id)
                                     .to_set

    self.collection = notifications.select do |n|
      topic_id = n.event&.topic_id
      if topic_id
        next false unless accessible_topic_ids.include?(topic_id)
        eventable = n.event.eventable
        eventable.respond_to?(:kept?) ? eventable.kept? : true
      else
        current_user.can?(:show, n.event&.eventable)
      end
    end
    respond_with_collection
  end

  def viewed
    service.viewed(user: current_user)
    render json: { success: :ok }
  end

  def accessible_records
    current_user.notifications.includes(:actor, event: :eventable).order(id: :desc)
  end
end
