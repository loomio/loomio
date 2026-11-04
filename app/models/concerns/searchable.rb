module Searchable
  extend ActiveSupport::Concern
  include PgSearch::Model

  included do
    multisearchable
    skip_callback :save, :after, :update_pg_search_document
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
end

module PgSearch::Multisearchable
  def update_pg_search_document
    PgSearch::Document.where(searchable: self).delete_all
    ActiveRecord::Base.connection.execute(self.class.pg_search_insert_statement(id: self.id))
  end
end
