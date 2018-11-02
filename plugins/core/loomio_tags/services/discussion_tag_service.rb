class DiscussionTagService
  def self.create(discussion_tag:, actor:)
    actor.ability.authorize! :create, discussion_tag

    return false unless discussion_tag.valid?
    discussion_tag.save!
    EventBus.broadcast 'discussion_tag_create', discussion_tag, actor
  end

  def self.destroy(discussion_tag:, actor:)
    actor.ability.authorize! :destroy, discussion_tag

    discussion_tag.destroy
    EventBus.broadcast 'discussion_tag_destroy', discussion_tag, actor
  end
end
