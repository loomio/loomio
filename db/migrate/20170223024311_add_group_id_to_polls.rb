class AddGroupIdToPolls < ActiveRecord::Migration
  def change
    add_column :polls, :group_id, :integer, null: true, index: true

    Poll.reset_column_information

    Poll.all.each do |poll|
      poll.update(group_id: poll.discussion.group_id) if poll.discussion
    end
  end
end
