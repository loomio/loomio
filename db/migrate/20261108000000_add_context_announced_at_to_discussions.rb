class AddContextAnnouncedAtToDiscussions < ActiveRecord::Migration[8.1]
  def change
    add_column :discussions, :context_announced_at, :datetime
  end
end
