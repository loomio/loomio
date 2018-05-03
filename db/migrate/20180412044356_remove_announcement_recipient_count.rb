class RemoveAnnouncementRecipientCount < ActiveRecord::Migration[5.1]
  def change
    remove_column :groups, :announcement_recipients_count
  end
end
