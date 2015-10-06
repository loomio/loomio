class GroupService
  def self.create(group:, actor:)
    group.creator = actor
    actor.ability.authorize! :create, group

    group.save && group.mark_as_setup! && group.add_admin!(actor)
    if group.is_parent?
      group.update default_group_cover: DefaultGroupCover.sample,
                   subscription: Subscription.new(kind: :trial, expires_at: 30.days.from_now)
    end
    group
  end

  def self.update(group:, params:, actor:)
    actor.ability.authorize! :update, group
    group.update params
    group
  end

  def self.archive(group:, actor:)
    actor.ability.authorize! :archive, group
    group.archive!
  end
end
