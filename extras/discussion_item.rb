class DiscussionItem
  include Routing
  attr_accessor :item

  delegate :icon, :position, :group, :actor, :header, :body, :time, :author_name, :to => :item

  alias :author :actor
  alias :created_at :time

  def title
    "#{actor.name} #{header}"
  end

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
      when 'motion_closed_by_user'
        DiscussionItems::MotionClosedByUser.new(event, event_item)
      when 'motion_close_date_edited'
        DiscussionItems::MotionCloseDateEdited.new(event, event_item)
      when 'discussion_title_edited'
        DiscussionItems::DiscussionTitleEdited.new(event, event_item)
      when 'discussion_description_edited'
        DiscussionItems::DiscussionDescriptionEdited.new(event, event_item)
      when 'motion_outcome_created'
        DiscussionItems::MotionOutcomeCreated.new(event, event_item)
      when 'motion_outcome_updated'
        DiscussionItems::MotionOutcomeUpdated.new(event, event_item)
      when 'motion_name_edited'
        DiscussionItems::MotionNameEdited.new(event, event_item)
      when 'motion_description_edited'
        DiscussionItems::MotionDescriptionEdited.new(event, event_item)
      else
        raise "unhandled event kind: #{event.kind}"
    end
  end
end
