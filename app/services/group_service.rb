class GroupService
  def self.create(group: group, actor: actor)
    group.creator = actor
    actor.ability.authorize! :create, group
    group.save! && group.mark_as_setup! && group.add_admin!(actor)
    group
  end

  def self.update(group: group, params: params, actor: actor)
    actor.ability.authorize! :update, group
    group.update! params
    group
  end

  def self.archive(group: group, actor: actor)
    actor.ability.authorize! :archive, group
    group.archive!
  end
end
