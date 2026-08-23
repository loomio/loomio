class TopicItems::NewComment < TopicItem
  include TopicItems::Publish::Chatbots
  include TopicItems::Publish::SubscriberEmails
  include TopicItems::Publish::LiveUpdate

  def self.publish!(comment)
    if comment.parent.present?
      MarkNotificationsAsReadWorker.perform_later(comment.parent_type, comment.parent_id, comment.author_id)
    end

    publish_and_mark_read!(comment,
                           reader: comment.author,
                           user: comment.author,
                           topic: comment.topic,
                           pinned: comment.should_pin)
  end
end
