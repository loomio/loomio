class UpdateTagWorker
  include Sidekiq::Worker

  def perform(group_id, old_name, new_name, color)
    group = Group.find(group_id)
    group_ids = group.id_and_subgroup_ids

    if old_name != new_name
      Tag.where(group_id: group_ids, name: new_name).delete_all
      Tag.where(group_id: group_ids, name: old_name).update_all(name: new_name)
    end

    Discussion.where(group_id: group_ids).where.contains(tags: [old_name]).find_each do |d|
      d.tags[d.tags.index(old_name)] = new_name
      d.update_column(:tags, d.tags.uniq)
    end

    Poll.where(group_id: group_ids).where.contains(tags: [old_name]).find_each do |p|
      p.tags[p.tags.index(old_name)] = new_name
      p.update_column(:tags, p.tags.uniq)
    end

    group_ids.each do |group_id|
      TagService.update_group_tags(group_id)
    end

    Tag.where(group_id: group_ids, name: new_name).update_all(color: color)

    TagService.update_org_tagging_counts(group.parent_or_self.id)
  end
end
