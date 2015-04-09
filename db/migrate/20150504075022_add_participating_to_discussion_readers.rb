class AddParticipatingToDiscussionReaders < ActiveRecord::Migration
  def change
    add_column :discussion_readers, :participating, :boolean, null: false, default: :false
  end
end
