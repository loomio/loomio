class CleanUpVersionsTable < ActiveRecord::Migration[6.0]
  def change
    execute "alter table versions drop column object"
    execute "delete from versions where object_changes is null"
  end
end
