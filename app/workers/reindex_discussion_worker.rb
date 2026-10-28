class ReindexDiscussionWorker < ApplicationJob
  queue_as :search_index

  def perform(discussion_id)
    SearchService.reindex_by_discussion_id(discussion_id)
  end
end
