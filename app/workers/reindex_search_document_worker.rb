class ReindexSearchDocumentWorker < ApplicationJob
  queue_as :search_index
  retry_on StandardError, wait: :polynomially_longer, attempts: 5

  def perform(searchable_type, searchable_id)
    searchable_type.constantize.find_by(id: searchable_id)&.update_pg_search_document
  end
end
