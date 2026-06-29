class ReindexDiscussionWorker < ApplicationJob
  def perform(discussion_id)
    SearchService.reindex_by_discussion_id(discussion_id)
  end
end
