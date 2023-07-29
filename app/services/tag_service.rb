class TagService
  def self.create(tag:, actor:)
    actor.ability.authorize! :create, tag

    return false unless tag.valid?
    tag.save!
    EventBus.broadcast 'tag_create', tag, actor
    MessageChannelService.publish_models([tag], group_id: tag.group.id)
    tag
  end

  def self.update(tag:, params:, actor:)
    actor.ability.authorize! :update, tag

    UpdateTagWorker.new.perform(tag.group_id, tag.name, params[:name].strip, params[:color])
    tag.reload

    MessageChannelService.publish_models([tag], group_id: tag.group.id)
    EventBus.broadcast 'tag_update', tag, actor
    tag
  end

  def self.destroy(tag:, actor:)
    actor.ability.authorize! :destroy, tag

    DestroyTagWorker.perform_async(tag.group_id, tag.name)
    EventBus.broadcast 'tag_destroy', tag, actor
  end

  def self.apply_colors(group_id)
    group_ids = Group.find(group_id).parent_or_self.id_and_subgroup_ids
    Tag.where(group_id: group_id, color: nil).each do |tag|
      if parent_tag = Tag.where(group_id: group_ids, name: tag.name).where.not(color: nil).first
        tag.update_columns(color: parent_tag.color)
      else
        tag.update_columns(color: Tag::COLORS.sample)
      end
    end
  end

  def self.update_group_and_org_tags(group_id)
    update_group_tags(group_id)
    update_org_tagging_counts(Group.find(group_id).parent_or_self.id)
  end

  def self.update_group_tags(group_id)
    return unless group = Group.find_by(id: group_id)

    names = (group.discussions.kept.select(:tags).pluck(:tags).flatten +
             group.polls.kept.select(:tags).pluck(:tags).flatten)

    counts = {}

    names.map(&:downcase).each do |dname|
      counts[dname] ||= 0
      counts[dname] += 1
    end

    group.tags.where.not(name: counts.keys).update_all(taggings_count: 0)

    if counts.any?
      attrs = counts.map do |dname, count|
        {name: names.find {|name| name.downcase == dname}, group_id: group.id, taggings_count: count}
      end
      Tag.upsert_all(attrs, unique_by: [:group_id, :name], record_timestamps: false)
    end

    apply_colors(group_id)
  end

  def self.update_org_tagging_counts(group_id)
    return unless group = Group.find_by(id: group_id)

    group_ids = group.id_and_subgroup_ids

    names = Tag.where(group_id: group_ids).pluck(:name).uniq

    attrs = Tag.where(group_id: group_ids).pluck(:name).map(&:downcase).uniq.map do |dname|
      count = Tag.where(group_id: group_ids, name: dname).sum(:taggings_count)
      {name: names.find {|name| name.downcase == dname}, group_id: group_id, org_taggings_count: count}
    end

    if attrs.any?
      Tag.upsert_all(attrs, unique_by: [:group_id, :name], record_timestamps: false)
    end

    apply_colors(group_id)
  end
end
