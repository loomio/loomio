class MigrateTagsWorker
  include Sidekiq::Worker

  def perform
    group_ids = []
    Tagging.where(taggable_type: 'Discussion').pluck(:taggable_id).uniq.each do |discussion_id|
      tag_ids = Tagging.where(taggable_id: discussion_id, taggable_type: 'Discussion').pluck(:tag_id)
      names = Tag.where(id: tag_ids).pluck(:name)
      if d = Discussion.find_by(id: discussion_id)
        group_ids.push d.group_id
        d.update_columns(tags: names.uniq) 
      end
    end

    Tagging.where(taggable_type: 'Poll').pluck(:taggable_id).uniq.each do |poll_id|
      tag_ids = Tagging.where(taggable_id: poll_id, taggable_type: 'Poll').pluck(:tag_id)
      names = Tag.where(id: tag_ids).pluck(:name)
      if p = Poll.find_by(id: poll_id)
        group_ids.push p.group_id
        p.update_columns(tags: names.uniq) 
      end
    end

    group_ids.each {|id| TagService.update_group_and_org_tags(id) }
    Group.where(id: group_ids).where(parent_id: nil).pluck(:id).each {|id| TagService.update_org_tagging_counts(id) }
  end
end
