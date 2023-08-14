class CreatePgSearchDocuments < ActiveRecord::Migration[7.0]
  def up
    say_with_time("Creating table for pg_search multisearch") do
      create_table :pg_search_documents do |t|
        t.text :content
        t.tsvector :ts_content
        t.references :author, index: true
        t.references :group, index: true
        t.references :discussion, index: true
        t.references :poll
        t.belongs_to :searchable, polymorphic: true, index: true
        t.timestamps null: false
        t.datetime :authored_at
        t.index ["ts_content"], name: "pg_search_documents_searchable_index", using: :gin
        t.index ["authored_at"], name: "pg_search_documents_authored_at_desc_index", order: {authored_at: :desc}
        t.index ["authored_at"], name: "pg_search_documents_authored_at_asc_index", order: {authored_at: :asc}
      end
    end
  end

  def down
    say_with_time("Dropping table for pg_search multisearch") do
      drop_table :pg_search_documents
    end
  end
end
