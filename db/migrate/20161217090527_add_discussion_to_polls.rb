class AddDiscussionToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :discussion_id, :integer, null: true
    add_column :polls, :group_id, :integer, null: true
    add_column :polls, :closing_at, :datetime, null: true
    add_column :polls, :closed_at, :datetime, null: true
    add_column :motions, :has_poll, :boolean, default: false
  end
end
