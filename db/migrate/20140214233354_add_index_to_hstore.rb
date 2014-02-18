class AddIndexToHstore < ActiveRecord::Migration
  def up
    execute "CREATE INDEX translations_gin_fields ON translations USING GIN(fields)"
  end
  
  def down
    execute "DROP INDEX translations_gin_fields"    
  end
end
