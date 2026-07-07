class MigrateTagsWorker < ApplicationJob
  def perform
    group_ids = []
    Tagging.where(taggable_type: 'Discussion').pluck(:taggable_id).uniq.each do |discussion_id|
      tag_ids = Tagging.where(taggable_id: discussion_id, taggable_type: 'Discussion').pluck(:tag_id)
      names = Tag.where(id: tag_ids).pluck(:name)
      if d = Discussion.find_by(id: discussion_id)
        group_ids.push d.group_id
        d.update_columns(tags: TagService.clean_tag_names(names))
      end
    end

    Tagging.where(taggable_type: 'Poll').pluck(:taggable_id).uniq.each do |poll_id|
      tag_ids = Tagging.where(taggable_id: poll_id, taggable_type: 'Poll').pluck(:tag_id)
      names = Tag.where(id: tag_ids).pluck(:name)
      if p = Poll.find_by(id: poll_id)
        group_ids.push p.group_id
        p.update_columns(tags: TagService.clean_tag_names(names))
      end
    end

    group_ids.uniq.each { |id| TagService.update_org_tags(id) }
  end
end
