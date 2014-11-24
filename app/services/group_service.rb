class GroupService
  def self.update(group: group, params: params, actor: actor)
    actor.ability.authorize! :update, group
    group.update! params
  end
end
