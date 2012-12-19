class ActivityItem
  attr_accessor :item

  delegate :icon, :position, :group, :actor, :header, :body, :time, :to => :item

  def initialize(event)
    event_item = event.eventable
    @item = case event.kind
      when 'new_motion'
        ActivityItems::NewMotion.new(event_item)
      when 'new_vote'
        ActivityItems::NewVote.new(event_item)
      when 'motion_blocked'
        ActivityItems::NewVote.new(event_item)
      when 'motion_closed'
        ActivityItems::MotionClosed.new(event, event_item)
      when 'motion_close_date_edited'
        ActivityItems::MotionCloseDateEdited.new(event, event_item)
      when 'new_discussion'
        ActivityItems::NewDiscussion.new(event_item)
      when 'discussion_title_edited'
        ActivityItems::DiscussionTitleEdited.new(event, event_item)
      when 'discussion_description_edited'
        ActivityItems::DiscussionDescriptionEdited.new(event, event_item)
    end
  end
end