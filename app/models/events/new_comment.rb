class Events::NewComment < Event
  include Events::Notify::ByEmail
  include Events::Notify::Mentions
  include Events::Notify::Chatbots
  include Events::Notify::Subscribers
  include Events::LiveUpdate

  def self.publish!(comment)
    if comment.parent.present?
      GenericWorker.perform_later('NotificationService', 'mark_as_read', comment.parent_type, comment.parent_id, comment.author_id)
    end

    publish_and_mark_read!(comment,
                           reader: comment.author,
                           user: comment.author,
                           topic: comment.topic,
                           pinned: comment.should_pin)
  end

end
