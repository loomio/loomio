class UpdateTagWorker
  include Sidekiq::Worker

  def perform(group_id, name, params)
    group = Group.find(group_id)
    group_ids = group.id_and_subgroup_ids

    Tag.transaction do
      Tag.where(group_id: group_ids, name: params[:name]).delete_all
      Tag.where(group_id: group_ids, name: name).update_all(name: params[:name], color: params[:color])

      Discussion.where(group_id: group_ids).where.contains(tags: [name]).find_each do |d|
        d.tags[d.tags.index(name)] = params[:name]
        d.update_column(:tags, d.tags.uniq)
      end

      Poll.where(group_id: group_ids).where.contains(tags: [name]).find_each do |p|
        p.tags[p.tags.index(name)] = params[:name]
        p.update_column(:tags, p.tags.uniq)
      end
    end

    group_ids.each do |group_id|
      TagService.update_group_tags(group_id)
    end

    TagService.update_org_tagging_counts(group.parent_or_self.id)
  end
end
