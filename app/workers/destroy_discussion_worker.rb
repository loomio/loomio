class DestroyDiscussionWorker
  include Sidekiq::Worker

  def perform(discussion_id)
    Discussion.find(discussion_id).destroy!
  end
end
