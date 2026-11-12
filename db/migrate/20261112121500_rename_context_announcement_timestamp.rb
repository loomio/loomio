class RenameContextAnnouncementTimestamp < ActiveRecord::Migration[8.1]
  def change
    rename_column :discussions, :context_announced_at, :context_changed_at
  end
end
