class RenameUncastStancesCountToUndecidedCount < ActiveRecord::Migration[5.2]
  def change
    return if column_exists? :polls, :undecided_count
    rename_column :polls, :uncast_stances_count, :undecided_count
  end
end
