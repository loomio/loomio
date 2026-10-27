module Searchable
  extend ActiveSupport::Concern
  include PgSearch::Model

  included do
    # Own the lifecycle instead of pg_search's synchronous save/delete callbacks.
    has_one :pg_search_document, as: :searchable, class_name: 'PgSearch::Document'
    after_commit :enqueue_search_index_update, on: [ :create, :update, :destroy ],
      if: -> { destroyed? || PgSearch.multisearch_enabled? }
  end

  class_methods do
    def rebuild_pg_search_documents
      SearchService.with_index_lock(name) do
        PgSearch::Document.where(searchable_type: name).delete_all
        connection.execute pg_search_insert_statement
      end
    end

    def pg_search_insert_statement(id: nil, author_id: nil)
      raise 'expected to be overwritten'
    end
  end

  # Explicit synchronous indexing remains available to maintenance tasks.
  def update_pg_search_document
    SearchService.reindex_record(self.class, id)
  end

  private

  def enqueue_search_index_update
    ReindexSearchDocumentWorker.perform_later(self.class.name, id)
  end
end
