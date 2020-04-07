class RenameUncastStancesCountToUndecidedCount < ActiveRecord::Migration[5.2]
  def change
    return if ENV['CANONICAL_HOST'] == 'www.loomio.org'
    rename_column :polls, :uncast_stances_count, :undecided_count
  end
end
