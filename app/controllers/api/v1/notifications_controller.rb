class API::V1::NotificationsController < API::V1::RestfulController
  def index
    # where event.eventable.group_id in current_user.group_ids
    self.collection = accessible_records.limit(50).select do |n|
        current_user.can? :show, n.event.eventable
        # case n.event.eventable_type
        # when "Discussion"
        #   current_user.group_ids.include?(n.event.eventable.group_id) || current_user.guest_discussion_ids.include?(n.event.eventable_id)
        # when "Comment"
        #   current_user.group_ids.include?(n.event.eventable.discussion.group_id) || current_user.guest_discussion_ids.include?(n.event.eventable.discussion_id)
        # when "Poll"
        #   current_user.group_ids.include?(n.event.eventable.group_id) || current_user.guest_poll_ids.include?(n.event.eventable_id)
        # when "Group"
        #   current_user.group_ids.include?(n.event.eventable.id)
        # when "Reaction"
        #   # recuse through reactable
        #   current_user.group_ids.include?(n.event.eventable.reactable.group_id)
        # when "Stance", "Outcome"
        #   current_user.group_ids.include?(n.event.eventable.poll.group_id) || current_user.guest_poll_ids.include?(n.event.eventable.poll_id)
        # else
        #   raise "unknown eventable_type: #{n.event.eventable_type}"
        # end
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
