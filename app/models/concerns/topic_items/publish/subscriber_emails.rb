module TopicItems::Publish::SubscriberEmails
  extend ActiveSupport::Concern

  included do
    after_create_commit :enqueue_subscriber_email_publication!
    after_create_commit :enqueue_subscriber_push_publication!
  end

  def enqueue_subscriber_email_publication!
    PublishSubscriberEmailsTopicItemWorker.perform_later(id)
  end

  def enqueue_subscriber_push_publication!
    PublishSubscriberPushTopicItemWorker.perform_later(id)
  end
end
