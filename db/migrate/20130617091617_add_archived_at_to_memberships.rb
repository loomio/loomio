class AddArchivedAtToMemberships < ActiveRecord::Migration

  class Group < ActiveRecord::Base
    has_many :memberships
    has_many :subgroups, :class_name => "Group", :foreign_key => 'parent_id'

    def archive!
      self.update_attribute(:archived_at, DateTime.now)
      memberships.update_all(:archived_at => DateTime.now)
      subgroups.each do |group|
        group.archive!
      end
    end
  end

  def up
    add_column :memberships, :archived_at, :datetime
    Group.where('archived_at is not null').each do |group|
      group.archive!
    end
  end

  def down
    remove_column :memberships, :archived_at
  end
end
