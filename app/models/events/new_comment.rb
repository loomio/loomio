class Events::NewComment < Event
  include Events::Notify::ByEmail
  include Events::Notify::ByWebPush
  include Events::Notify::Mentions
  include Events::Notify::Chatbots
  include Events::Notify::Subscribers
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

end
