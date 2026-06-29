class ReindexCommentWorker < ApplicationJob
  def perform(comment_id)
    SearchService.reindex_by_comment_id(comment_id)
  end
end
