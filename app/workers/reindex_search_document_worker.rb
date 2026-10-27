class ReindexSearchDocumentWorker < SearchIndexJob
  def perform(searchable_type, searchable_id)
    SearchService.reindex_record(searchable_type.constantize, searchable_id)
  end
end
