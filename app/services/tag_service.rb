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

    return if names.empty?

    counts = {}

    names.map(&:downcase).each do |dname|
      counts[dname] ||= 0
      counts[dname] += 1
    end

    group.tags.where.not(name: counts.keys).update_all(taggings_count: 0)

    present = Tag.where(group_id: group_id, name: counts.keys).pluck(:name).map(&:downcase)
    missing = counts.keys - present

    Tag.where(group_id: group_id, name: present).each do |tag|
      tag.update_column(:taggings_count, counts[tag.name.downcase])
    end

    missing.each do |dname|
      Tag.insert({group_id: group_id,
                  name: names.find {|name| name.downcase == dname},
                  taggings_count: counts[dname]})
    end

    apply_colors(group_id)
  end

  def self.update_org_tagging_counts(group_id)
    return unless group = Group.find_by(id: group_id)

    group_ids = group.id_and_subgroup_ids

    names = Tag.where(group_id: group_ids).pluck(:name).uniq
    counts = {}

    Tag.where(group_id: group_ids).pluck(:name).map(&:downcase).uniq.map do |dname|
      counts[dname] = Tag.where(group_id: group_ids, name: dname).sum(:taggings_count) 
    end

    group.tags.where.not(name: counts.keys).update_all(org_taggings_count: 0)

    present = Tag.where(group_id: group_id, name: names).pluck(:name).map(&:downcase)
    missing = counts.keys - present

    Tag.where(group_id: group_id, name: present).each do |tag|
      tag.update_column(:org_taggings_count, counts[tag.name.downcase])
    end

    missing.each do |dname|
      Tag.insert({group_id: group_id,
                  name: names.find {|name| name.downcase == dname},
                  org_taggings_count: counts[dname]})
    end

    apply_colors(group_id)
  end
end
