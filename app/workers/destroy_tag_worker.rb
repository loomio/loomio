class DestroyTagWorker
  include Sidekiq::Worker

  def perform(group_id, name)
    group = Group.find(group_id)
    group_ids = group.id_and_subgroup_ids

    Tag.transaction do
      Tag.where(group_id: group_ids, name: name).delete_all

      Topic.where(group_id: group_ids).where.contains(tags: [name]).find_each do |t|
        t.update_column(:tags, t.tags - Array(name))
      end
    end

    TagService.update_org_tagging_counts(group.parent_or_self.id)
  end
end
