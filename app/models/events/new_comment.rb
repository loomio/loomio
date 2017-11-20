class Events::NewComment < Event
  include Events::Notify::ByEmail
  include Events::Notify::Mentions
  include Events::LiveUpdate

  def self.publish!(comment)
    super comment,
          user: comment.author,
          discussion: comment.discussion
  end

  private

  def email_recipients
    Queries::UsersByVolumeQuery.loud(eventable.discussion)
                               .without(eventable.author)
                               .without(eventable.mentioned_group_members)
                               .without(eventable.parent_author)
  end
end
