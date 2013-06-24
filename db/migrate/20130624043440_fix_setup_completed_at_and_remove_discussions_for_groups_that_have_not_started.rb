class FixSetupCompletedAtAndRemoveDiscussionsForGroupsThatHaveNotStarted < ActiveRecord::Migration
  class Group < ActiveRecord::Base
    scope :parents_only, where(:parent_id => nil)
    has_many :discussions
  end

  def up
    Group.parents_only.where(memberships_count: 0).find_each do |group|
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
