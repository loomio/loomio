class UpdateTagWorker < ApplicationJob
  def perform(group_id, old_name, new_name, color)
    group = Group.find(group_id).parent_or_self
    group_ids = group.id_and_subgroup_ids
    TopicItem.transaction do
      old_key = TagService.normalized_tag_name(old_name)
      new_name = TagService.clean_tag_name(new_name)
      new_key = TagService.normalized_tag_name(new_name)

      if old_key != new_key
        Tag.where(group_id: group_ids).select { |tag| TagService.normalized_tag_name(tag.name) == new_key }.each(&:destroy!)
      end

      old_tags = Tag.where(group_id: group_ids).select { |tag| TagService.normalized_tag_name(tag.name) == old_key }
      canonical = old_tags.find { |tag| tag.group_id == group.id } || old_tags.first
      (old_tags - Array(canonical)).each(&:destroy!)
      canonical&.update!(group: group, name: new_name)

      TopicItem.where(topic_id: Topic.where(group_id: group_ids).select(:id)).where('cardinality(tags) > 0').find_each do |item|
        next unless item.tags.any? { |tag| TagService.normalized_tag_name(tag) == old_key }

        item.update!(tags: TagService.clean_tag_names(item.tags.map { |tag|
          TagService.normalized_tag_name(tag) == old_key ? new_name : tag
        }))
      end

      TagService.update_org_tags(group.id)

      Tag.where(group_id: group.id).select { |tag| TagService.normalized_tag_name(tag.name) == new_key }.each do |tag|
        tag.update!(color: color)
      end
    end
  end
end
