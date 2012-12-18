class ActivityItem
  attr_reader :icon, :position, :group, :actor, :header, :body, :time

  def initialize(event)
    event_item = event.eventable
    @item = case event.kind
      when 'new_motion'
        NewMotionActivityItem.new(event_item)
      when 'new_vote'
        NewVoteActivityItem.new(event_item)
      when 'motion_blocked'
        NewVoteActivityItem.new(event_item)
      when 'motion_closed'
        MotionClosedActivityItem.new(event, event_item)
      when 'motion_close_date_edited'
        MotionCloseDateEditedActivityItem.new(event, event_item)
      when 'new_discussion'
        NewDiscussionActivityItem.new(event_item)
      when 'discussion_title_edited'
        DiscussionTitleEditedActivityItem.new(event, event_item)
      when 'discussion_description_edited'
        DiscussionDescriptionEditedActivityItem.new(event, event_item)
    end
  end

  def icon
    @item.icon
  end

  def position
    @item.position
  end

  def group
    @item.group
  end

  def actor
    @item.actor
  end

  def header
    @item.header
  end

  def body
    @item.body
  end

  def time
    @item.time
  end
end