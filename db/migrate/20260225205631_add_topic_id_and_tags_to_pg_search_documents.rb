class AddTopicIdAndTagsToPgSearchDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :pg_search_documents, :topic_id, :bigint
    add_column :pg_search_documents, :tags, :string, array: true, default: []
    add_index :pg_search_documents, :topic_id
    add_index :pg_search_documents, :tags, using: :gin
  end
end
