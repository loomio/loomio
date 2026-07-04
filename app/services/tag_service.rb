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

    destroy_by_name(tag.group_id, tag.name)
    EventBus.broadcast 'tag_destroy', tag, actor
  end

  def self.destroy_by_name(group_id, name)
    group = Group.find(group_id)
    group_ids = group.id_and_subgroup_ids

    Tag.transaction do
      Tag.where(group_id: group_ids, name: name).destroy_all

      Topic.where(group_id: group_ids).where("topics.tags @> ARRAY[?]::varchar[]", name).find_each do |topic|
        topic.update_column(:tags, topic.tags - Array(name))
      end
    end

    update_org_tagging_counts(group.parent_or_self.id)
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
    return unless group = Group.find_by(id: group_id)
    update_group_tags(group_id)
    update_org_tagging_counts(group.parent_or_self.id)
  end

  def self.update_group_tags(group_id)
    return unless group = Group.find_by(id: group_id)

    names = group.topics.pluck(:tags).flatten

    return if names.empty?

    counts = {}

    names.map(&:downcase).each do |dname|
      counts[dname] ||= 0
      counts[dname] += 1
    end

    group.tags.where.not(name: counts.keys).update_all(taggings_count: 0)

    present = Tag.where(group_id: group_id, name: counts.keys).pluck(:name).map(&:downcase)
    missing = counts.keys - present

    if present.any?
      Tag.upsert_all(
        present.map { |name| {group_id: group_id, name: name, taggings_count: counts[name]} },
        unique_by: [:group_id, :name],
        update_only: [:taggings_count]
      )
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
    
    return if names.empty?

    counts = {}
    Tag.where(group_id: group_ids).group(:name).sum(:taggings_count).each do |name, count|
      counts[name.downcase] = (counts[name.downcase] || 0) + count
    end

    group.tags.where.not(name: counts.keys).update_all(org_taggings_count: 0)

    present = Tag.where(group_id: group_id, name: names).pluck(:name).map(&:downcase)
    missing = counts.keys - present

    if present.any?
      Tag.upsert_all(
        present.map { |name| {group_id: group_id, name: name, org_taggings_count: counts[name]} },
        unique_by: [:group_id, :name],
        update_only: [:org_taggings_count]
      )
    end

    missing.each do |dname|
      Tag.insert({group_id: group_id,
                  name: names.find {|name| name.downcase == dname},
                  org_taggings_count: counts[dname]})
    end

    apply_colors(group_id)
  end
end
