class ChangePinnedToPinnedAt < ActiveRecord::Migration[6.1]
  def change
    add_column :discussions, :pinned_at, :datetime, default: nil
    Discussion.where(pinned: true).update_all(pinned_at: Time.now)
  end
end
