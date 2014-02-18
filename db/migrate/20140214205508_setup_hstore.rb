class SetupHstore < ActiveRecord::Migration
  def change
    execute "CREATE EXTENSION IF NOT EXISTS hstore"
  end

  def down
    execute "DROP EXTENSION IF EXISTS hstore"
  end
end
