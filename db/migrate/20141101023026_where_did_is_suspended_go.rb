class WhereDidIsSuspendedGo < ActiveRecord::Migration
  def change
    unless column_exists?(:memberships, :is_suspended)
      add_column :memberships, :is_suspended, :boolean, default: false, null: false
    end
  end
end
