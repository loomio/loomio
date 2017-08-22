class EventCollection
  attr_reader :events

  def initialize(events)
    @events = Array(events)
  end

  def any?
    @events.any?
  end

  def serialize!(scope = {})
    Events::ArraySerializer.new(self, scope: default_scope.merge(scope)).as_json
  end

  private

  def default_scope
    { cache: { reactors: reactors, attachments: attachments, mentions: mentions } }
  end

  def reactors
    @reactors ||= User.joins(:reactions)
                      .select('users.*').select('reactions.reactable_id')
                      .where('reactions.reactable_id': event_comment_ids, 'reactions.reactable_type': 'Comment')
                      .group_by(&:reactable_id)
  end

  def mentions
    @mentions ||= Comment.find(event_comment_ids).map { |c| [c.id, c.mentioned_usernames] }.to_h
  end

  def attachments
    @attachments ||= Attachment.where(
      attachable_type: "Comment",
      attachable_id: event_comment_ids
    ).group_by(&:attachable_id)
  end

  def event_comment_ids
    @event_comment_ids ||= @events.select { |event| event.kind == 'new_comment' }.map(&:eventable_id)
  end
end
