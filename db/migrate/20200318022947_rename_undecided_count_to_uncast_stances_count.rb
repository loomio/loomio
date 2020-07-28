class RenameUndecidedCountToUncastStancesCount < ActiveRecord::Migration[5.2]
  def change
    rename_column :polls, :undecided_count, :uncast_stances_count
  end
end
