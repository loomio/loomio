class TopicItems::NewComment < TopicItem
  include TopicItems::Publish::Chatbots
  include TopicItems::Publish::SubscriberEmails
  include TopicItems::Publish::LiveUpdate

  after_create_commit :enqueue_parent_notifications_read!

  private

  def enqueue_parent_notifications_read!
    return unless itemable.parent_id

    MarkNotificationsAsReadWorker.perform_later(
      itemable.parent_type,
      itemable.parent_id,
      itemable.author_id
    )
  end
end
