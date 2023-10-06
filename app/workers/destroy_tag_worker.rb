class DestroyTagWorker
  include Sidekiq::Worker

  def perform(group_id, name)
    group = Group.find(group_id)
    group_ids = group.id_and_subgroup_ids

    Tag.transaction do
      Tag.where(group_id: group_ids, name: name).delete_all

      Discussion.where(group_id: group_ids).where.contains(tags: [name]).find_each do |d|
        d.update_column(:tags, d.tags - Array(name))
      end

      Poll.where(group_id: group_ids).where.contains(tags: [name]).find_each do |p|
        p.update_column(:tags, p.tags - Array(name))
      end
    end

    TagService.update_org_tagging_counts(group.parent_or_self.id)
  end
end
