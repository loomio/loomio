class ReindexAuthorWorker < SearchIndexJob
  def perform(user_id)
    SearchService.reindex_by_author_id(user_id)
  end
end
