class AddDiscussionsCount < ActiveRecord::Migration
  class Group < ActiveRecord::Base
    has_many :discussions
  end
  def up
    add_column :groups, :discussions_count, :integer, :default => 0, :null => false
    Group.reset_column_information
    Group.all.each do |group|
      group.discussions_count = group.discussions.count
      group.save!
    end
  end
  def down
    remove_column :groups, :discussions_count
  end
end
