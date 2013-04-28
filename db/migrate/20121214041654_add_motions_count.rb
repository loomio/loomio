class AddMotionsCount < ActiveRecord::Migration
  class Group < ActiveRecord::Base
    has_many :discussions
    has_many :motions, :through => :discussions
  end
  def up
    add_column :groups, :motions_count, :integer, :default => 0, :null => false
    Group.reset_column_information
    Group.all.each do |group|
      group.motions_count = group.motions.count
      group.save!
    end
  end
  def down
    remove_column :groups, :motions_count
  end
end
