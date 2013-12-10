class ArchiveDiscussionsInArchivedGroups < ActiveRecord::Migration
  def up
    archived_groups = Group.unscoped.where('archived_at IS NOT NULL')
    archived_groups.each { |g| g.discussions.each &:archive! }
  end

  def down
  end
end
