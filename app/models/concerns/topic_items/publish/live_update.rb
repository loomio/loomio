module TopicItems::Publish::LiveUpdate
  extend ActiveSupport::Concern

  included do
    after_create_commit :enqueue_live_update_publication!
  end

  def enqueue_live_update_publication!
    PublishLiveUpdateTopicItemWorker.perform_later(id)
  end
end
