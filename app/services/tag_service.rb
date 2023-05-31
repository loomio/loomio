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
    counts = {}

    group.discussions.kept.select(:tags).pluck(:tags).each do |tags|
      tags.each do |tag|
        counts[tag] ||= 0
        counts[tag] += 1
      end
    end

    group.polls.kept.select(:tags).pluck(:tags).each do |tags|
      tags.each do |tag|
        counts[tag] ||= 0
        counts[tag] += 1
      end
    end

    group.tags.where.not(name: counts.keys).delete_all
    counts.each_pair do |name, count|
      if tag = group.tags.find_by(name: name)
        tag.update(taggings_count: count)
      else
        group.tags.create(name: name, taggings_count: count)
      end
    end
  end

  def self.update_org_tagging_counts(group_id)
    return unless group = Group.find_by(id: group_id)
    group_ids = group.id_and_subgroup_ids

    counts = {}

    Discussion.where(group_id: group_ids).kept.select(:tags).pluck(:tags).each do |tags|
      tags.each do |tag|
        counts[tag] ||= 0
        counts[tag] += 1
      end
    end

    Poll.where(group_id: group_ids).kept.select(:tags).pluck(:tags).each do |tags|
      tags.each do |tag|
        counts[tag] ||= 0
        counts[tag] += 1
      end
    end

    counts.each_pair do |name, count|
      if tag = group.tags.find_by(name: name)
        tag.update(org_taggings_count: count)
      else
        group.tags.create(name: name, org_taggings_count: count)
      end
    end
  end

end
