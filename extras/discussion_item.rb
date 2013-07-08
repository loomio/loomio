class DiscussionItem
  attr_accessor :item

  delegate :icon, :position, :group, :actor, :header, :body, :time, :to => :item

  def initialize(event)
    event_item = event.eventable
    @item = case event.kind
      when 'new_discussion'
        DiscussionItems::NewDiscussion.new(event, event_item)
      when 'new_motion'
        DiscussionItems::NewMotion.new(event_item)
      when 'new_vote'
        DiscussionItems::NewVote.new(event_item)
      when 'motion_blocked'
        DiscussionItems::NewVote.new(event_item)
      when 'motion_closed'
        DiscussionItems::MotionClosed.new(event, event_item)
      when 'motion_edited'
        DiscussionItems::MotionEdited.new(event, event_item)
      when 'discussion_title_edited'
        DiscussionItems::DiscussionTitleEdited.new(event, event_item)
      when 'discussion_description_edited'
        DiscussionItems::DiscussionDescriptionEdited.new(event, event_item)
    end
  end
end