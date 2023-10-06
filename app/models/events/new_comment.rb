class Events::NewComment < Event
  include Events::Notify::ByEmail
  include Events::Notify::Mentions
  include Events::Notify::Chatbots
  include Events::LiveUpdate

  def self.publish!(comment)
    if comment.parent.present?
      GenericWorker.perform_async('NotificationService', 'mark_as_read', comment.parent_type, comment.parent_id, comment.author_id)
    end

    super comment,
          user: comment.author,
          discussion: comment.discussion,
          pinned: comment.should_pin
  end

  private
  def email_recipients
    Queries::UsersByVolumeQuery.loud(eventable.discussion)
                               .where.not(id: eventable.author)
                               .where.not(id: eventable.mentioned_users)
                               .where.not(id: eventable.parent_author).distinct
  end
end
