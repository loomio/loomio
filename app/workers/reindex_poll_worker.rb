class ReindexPollWorker < ApplicationJob
  def perform(poll_id)
    SearchService.reindex_by_poll_id(poll_id)
  end
end
