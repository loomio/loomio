class ReindexPollWorker < ApplicationJob
  queue_as :search_index

  def perform(poll_id)
    SearchService.reindex_by_poll_id(poll_id)
  end
end
