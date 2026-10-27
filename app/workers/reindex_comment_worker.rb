class ReindexCommentWorker < ApplicationJob
  queue_as :search_index

  def perform(comment_id)
    SearchService.reindex_by_comment_id(comment_id)
  end
end
