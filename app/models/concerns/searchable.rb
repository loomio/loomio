module Searchable
  extend ActiveSupport::Concern

  included do
    has_many :pg_search_documents, as: :searchable, class_name: "PgSearch::Document", dependent: :delete_all
    after_save_commit :enqueue_search_index_update, if: -> { PgSearch.multisearch_enabled? }
  end

  class_methods do
    def rebuild_pg_search_documents
      connection.execute pg_search_insert_statement
    end

    def pg_search_insert_statement(id: nil, author_id: nil)
      raise 'expected to be overwritten'
    end
  end

  def enqueue_search_index_update
    ReindexSearchDocumentWorker.perform_later(self.class.name, id)
  end

  def update_pg_search_document
    pg_search_documents.delete_all
    ActiveRecord::Base.connection.execute(self.class.pg_search_insert_statement(id: self.id))
  end
end
