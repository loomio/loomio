class RemoveUselessDiscussionReaders < ActiveRecord::Migration[5.2]
  def change
    DiscussionReader.where(last_read_at: nil, inviter_id: nil).delete_all
  end
end
