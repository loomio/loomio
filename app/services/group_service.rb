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

  def self.mark_as_read(group:, actor:)
    actor.ability.authorize! :mark_as_read, group
    readable_discussions = group.discussions.select { |d| actor.ability.can? :mark_as_read, d }
    cache = DiscussionReaderCache.new(user: actor, discussions: readable_discussions)
    readable_discussions.each { |discussion| cache.get_for(discussion).viewed! }
  end
end
