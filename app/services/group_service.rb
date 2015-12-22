module GroupService
  def self.create(group:, actor:)
    group.creator = actor
    actor.ability.authorize! :create, group

    return false unless group.valid?
    group.save!

    Loomio::EventBus.broadcast('group_create', group, actor)
  end

  def self.update(group:, params:, actor:)
    actor.ability.authorize! :update, group

    group.assign_attributes(params)
    # we have to apply group_privacy last so it can override any other settings
    group.group_privacy = params[:group_privacy] if params.has_key?(:group_privacy)

    return false unless group.valid?
    group.save!

    Loomio::EventBus.broadcast('group_update', group, params, actor)
  end

  def self.archive(group:, actor:)
    actor.ability.authorize! :archive, group
    group.archive!
    Loomio::EventBus.broadcast('group_archive', group, actor)
  end
end
