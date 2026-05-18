class BackfillOpenedAtOnPolls < ActiveRecord::Migration[7.0]
  def up
    execute "UPDATE polls SET opened_at = created_at WHERE opened_at IS NULL"
  end

  def down
    execute "UPDATE polls SET opened_at = NULL"
  end
end
