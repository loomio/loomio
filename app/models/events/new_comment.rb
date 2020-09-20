class Events::NewComment < Event
  include Events::Notify::ByEmail
  include Events::Notify::Mentions
  include Events::Notify::ThirdParty
  include Events::LiveUpdate

  def self.publish!(comment)
    super comment,
          user: comment.author,
          discussion: comment.discussion,
          pinned: comment.should_pin
  end

  private

  def notify_webhooks?
    !(eventable.discussion.visible_to != 'discussion')
  end

  def email_recipients
    Queries::UsersByVolumeQuery.loud(eventable.discussion)
                               .where.not(id: eventable.author)
                               .where.not(id: eventable.mentioned_users)
                               .where.not(id: eventable.parent_author).distinct
  end
end
