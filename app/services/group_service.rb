class GroupService
  def self.create(group:, actor:)
    group.creator = actor
    actor.ability.authorize! :create, group
    group.save! && group.mark_as_setup! && group.add_admin!(actor)
    group
  end

  def self.update(group:, params:, actor:)
    actor.ability.authorize! :update, group
    group.update! params
    group
  end

  def self.archive(group: nil, actor:, params: {})
    group ||= ModelLocator.new(:group, params).locate
    actor.ability.authorize! :archive, group
    group.archive!
  end
end
