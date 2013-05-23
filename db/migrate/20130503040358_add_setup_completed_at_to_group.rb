class AddSetupCompletedAtToGroup < ActiveRecord::Migration
  class Group < ActiveRecord::Base
  end

  def up
    add_column :groups, :setup_completed_at, :datetime

    Group.all.each do |group|
      group.setup_completed_at = group.created_at
      group.save
    end
  end

  def down
    remove_column :groups, :setup_completed_at
  end
end
