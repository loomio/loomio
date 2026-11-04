class ReindexAuthorWorker < ApplicationJob
  queue_as :search_index

  def perform(user_id)
    SearchService.reindex_by_author_id(user_id)
  end
end
