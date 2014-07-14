class UpdateCounterCaches < ActiveRecord::Migration
  def up
    remove_column :groups, :motions_count
    add_column :discussions, :motions_count, :integer, default: 0

    Discussion.reset_column_information
    Group.reset_column_information

    Group.update_all discussions_count: 0
    Discussion.update_all motions_count: 0
  end

  def down
    remove_column :discussions, :motions_count
    add_column :groups, :motions_count, :integer, default: 0
  end
end
