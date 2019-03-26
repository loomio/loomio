class TagService
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
