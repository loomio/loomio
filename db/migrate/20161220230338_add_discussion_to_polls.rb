class AddDiscussionToPolls < ActiveRecord::Migration
  def change
    create_table :poll_did_not_votes do |t|
      t.belongs_to :poll
      t.belongs_to :user
    end
    add_column :polls, :discussion_id, :integer
    add_column :polls, :key, :string, null: false
  end
end
