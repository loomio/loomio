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

    tag.assign_attributes(params.slice(:name, :color))

    return false unless tag.valid?
    tag.save!
    MessageChannelService.publish_models([tag], group_id: tag.group.id)
    EventBus.broadcast 'tag_update', tag, actor
    tag
  end

  def self.destroy(tag:, actor:)
    actor.ability.authorize! :destroy, tag

    tag.destroy
    EventBus.broadcast 'tag_destroy', tag, actor
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
      tags = counts.map do |dname, count|
        {name: names.find {|name| name.downcase == dname}, group_id: group.id, taggings_count: count}
      end
      byebug
      Tag.upsert_all(tags, unique_by: [:group_id, :name], record_timestamps: false)
    end

    update_org_tagging_counts(group.parent_or_self.id)
  end

  def self.update_org_tagging_counts(group_id)
    return unless group = Group.find_by(id: group_id)

    group_ids = group.id_and_subgroup_ids

    names = Discussion.where(group_id: group_ids).kept.select(:tags).pluck(:tags).flatten + 
            Poll.where(group_id: group_ids).kept.select(:tags).pluck(:tags).flatten

    counts = {}

    names.map(&:downcase).each do |dname|
      counts[dname] ||= 0
      counts[dname] += 1
    end

    if counts.any?
      tags = counts.map do |dname, count|
        { name: names.find {|name| name.downcase == dname}, group_id: group.id, org_taggings_count: count}
      end

      Tag.upsert_all(tags, unique_by: [:group_id, :name], record_timestamps: false)
    end
  end
end
