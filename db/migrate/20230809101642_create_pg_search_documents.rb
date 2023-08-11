class CreatePgSearchDocuments < ActiveRecord::Migration[7.0]
  def up
    say_with_time("Creating table for pg_search multisearch") do
      create_table :pg_search_documents do |t|
        t.text :content
        t.references :author, index: true
        t.references :group, index: true
        t.references :discussion, index: true
        t.references :poll, index: true
        t.belongs_to :searchable, polymorphic: true, index: true
        t.timestamps null: false
      end
    end
  end

  def down
    say_with_time("Dropping table for pg_search multisearch") do
      drop_table :pg_search_documents
    end
  end
end
