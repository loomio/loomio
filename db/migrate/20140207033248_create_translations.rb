class CreateTranslations < ActiveRecord::Migration
  def up
    execute "CREATE EXTENSION IF NOT EXISTS hstore"

  	create_table :translations do |t|
  		t.integer :translatable_id
  		t.string :translatable_type
  		t.column :fields, :hstore
  		t.string :language
  		t.timestamps
  	end
    
    execute "CREATE INDEX translations_gin_fields ON translations USING GIN(fields)"
  
  end
  
  def down
    execute "DROP INDEX IF EXISTS translations_gin_fields"
    drop_table :translations
    execute "DROP EXTENSION IF EXISTS hstore"
  end
  
end
