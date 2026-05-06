class DropPgheroSchema < ActiveRecord::Migration[8.0]
  def up
    execute "DROP SCHEMA IF EXISTS pghero CASCADE"
  end
end
