class DestroyDiscussionWorker < ApplicationJob
  def perform(discussion_id)
    Discussion.discarded.find(discussion_id).destroy!
  end
end
