module GroupService
  def self.ab_test_alternative?(group)
    group.segment_seed % 2 == 0
  end

  def self.create(group:, actor: )
    actor.ability.authorize! :create, group

    return false unless group.valid?

    if group.is_parent?
      group.update(default_group_cover: DefaultGroupCover.sample)
      ExampleContent.new(group).add_to_group!

      if SubscriptionService.available?
        group.subscription = Subscription.new_gift if ab_test_alternative?(group)
      end
    else
      group.save!
    end

    group.add_admin! actor if actor.is_logged_in?

    EventBus.broadcast('group_create', group, actor)
  end

  def self.update(group:, params:, actor:)
    actor.ability.authorize! :update, group

    group.assign_attributes(params)
    group.group_privacy = params[:group_privacy] if params.has_key?(:group_privacy)
    privacy_change = PrivacyChange.new(group)

    return false unless group.valid?
    group.save!
    privacy_change.commit!

    EventBus.broadcast('group_update', group, params, actor)
  end

  def self.archive(group:, actor:)
    actor.ability.authorize! :archive, group
    group.archive!
    EventBus.broadcast('group_archive', group, actor)
  end
end
