class FixSetupCompletedAtAndRemoveDiscussionsForGroupsThatHaveNotStarted < ActiveRecord::Migration
  class Group < ActiveRecord::Base
    has_many :discussions
  end

  def up
    Group.where(parent_id: nil, memberships_count: 0).find_each do |group|
      group.update_attribute(:setup_completed_at, nil)
      group.discussions.each do |d|
        puts d.title
      end
      group.discussions.each(&:destroy)
    end

    change_column :group_requests, :max_size, :integer, default: 300
  end

  def down
  end
end
