class TagService
  def self.update_model(discussion:, tags:)
    group = discussion.group.parent_or_self

    tag_names = Array(tags).uniq.sort

    existing_tag_names = Tag.where(group: group, name: tag_names).pluck(:name)
    (tag_names - existing_tag_names).each do |tag_name|
      Tag.create(name: tag_name, group: group, color: "#bbb")
    end

    DiscussionTag.where(discussion: discussion).destroy_all

    Tag.where(group: group, name: tag_names).each do |tag|
      DiscussionTag.create(discussion: discussion, group: group, tag: tag)
    end

    discussion.info[:tag_names] = tag_names
    discussion.save(validate: false)

    group.info[:tag_names] = Tag.where(group: group).where('discussion_tags_count > 0').pluck(:name)
    group.save(validate: false)

    discussion
  end

  def self.refresh_tag_info!
    Discussion.where(id: DiscussionTag.pluck(:discussion_id)).each do |discussion|
      discussion.info[:tag_names] = DiscussionTag.joins(:tag).where(discussion_id: discussion.id).pluck('tags.name')
      discussion.save(validate: false)
    end

    Group.where(id: Tag.pluck(:group_id)).each do |group|
      group.info[:tag_names] = Tag.where(group: group).pluck(:name)
      group.save(validate: false)
    end
  end


  def self.create(tag:, actor:)
    actor.ability.authorize! :create, tag

    return false unless tag.valid?
    tag.save!
    EventBus.broadcast 'tag_create', tag, actor
  end

  def self.update(tag:, params:, actor:)
    actor.ability.authorize! :update, tag

    tag.assign_attributes(params.slice(:name, :color))

    return false unless tag.valid?
    tag.save!
    EventBus.broadcast 'tag_update', tag, actor
  end

  def self.destroy(tag:, actor:)
    actor.ability.authorize! :destroy, tag

    tag.destroy
    EventBus.broadcast 'tag_destroy', tag, actor
  end
end
