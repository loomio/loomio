class GroupService
  def self.create(group:, actor:)
    group.creator = actor
    actor.ability.authorize! :create, group

    group.save && group.add_admin!(actor)
    if group.is_parent?
      group.update default_group_cover: DefaultGroupCover.sample,
                   subscription: Subscription.new_trial
      ExampleContent.add_to_group(group)
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
