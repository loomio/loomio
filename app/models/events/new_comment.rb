class Events::NewComment < Event
  include Events::Notify::ByEmail
  include Events::Notify::Mentions
  include Events::LiveUpdate

  def self.publish!(comment)
    super comment,
          user: comment.author,
          parent: comment.parent_event,
          discussion: comment.discussion
  end

  private

  def email_recipients
    Queries::UsersByVolumeQuery.loud(eventable.discussion)
                               .where.not(id: eventable.author)
                               .where.not(id: eventable.mentioned_group_members)
                               .where.not(id: eventable.parent_author)
  end
end
