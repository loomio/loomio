class ReindexPollWorker < SearchIndexJob
  def perform(poll_id)
    SearchService.reindex_by_poll_id(poll_id)
  end
end
