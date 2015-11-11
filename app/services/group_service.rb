module GroupService
  def self.create(group:, actor:)
    group.creator = actor
    actor.ability.authorize! :create, group

    if group.save
      if group.is_parent?
        group.update default_group_cover: DefaultGroupCover.sample,
                     subscription: Subscription.new_trial
        ExampleContent.add_to_group(group)
      end

      group.add_admin!(actor)
      true
    end
  end

  def self.privatize_group_discussions(group)
  end

  def self.update(group:, params:, actor:)
    actor.ability.authorize! :update, group

    group.attributes = params
    # we have to apply group_privacy last so it can override any other settings
    group.group_privacy = params[:group_privacy] if params.has_key?(:group_privacy)
    privacy_change = PrivacyChange.new(group)

    if group.save
      privacy_change.commit!
      true
    end
  end

  def self.archive(group:, actor:)
    actor.ability.authorize! :archive, group
    group.archive!
  end
end
