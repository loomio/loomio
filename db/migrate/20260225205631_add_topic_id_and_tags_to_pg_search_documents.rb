class AddTopicIdAndTagsToPgSearchDocuments < ActiveRecord::Migration[8.0]
  def change
    unless column_exists?(:pg_search_documents, :topic_id)
      add_column :pg_search_documents, :topic_id, :bigint
    end
    unless column_exists?(:pg_search_documents, :tags)
      add_column :pg_search_documents, :tags, :string, array: true, default: []
    end
    unless index_exists?(:pg_search_documents, :topic_id)
      add_index :pg_search_documents, :topic_id
    end
    unless index_exists?(:pg_search_documents, :tags)
      add_index :pg_search_documents, :tags, using: :gin
    end
  end
end
