module GroupService
  def self.create(group:, actor: )
    actor.ability.authorize! :create, group

    return false unless group.valid?

    group.is_referral = actor.groups.size > 0

    if group.is_formal_group? && group.is_parent?
      group.default_group_cover = DefaultGroupCover.sample
      group.creator             = actor if actor.is_logged_in?
      ExampleContent.new(group).add_to_group!
    else
      group.save!
    end

    EventBus.broadcast('group_create', group, actor)
  end

  def self.publish(group:, params:, actor:)
    actor.ability.authorize! :publish, group

    raise Group::NoIdentityFoundError.new unless identity = actor.identity_for(params[:identity_type])

    group.make_announcement = params[:make_announcement]
    group.group_identities.find_or_create_by(identity: identity).tap do |group_identity|
      group_identity.update(
        slack_channel_id: params[:identifier],
        slack_channel_name: params[:channel]
      )
    end


    Events::GroupPublished.publish!(group, actor, identity.id)
    EventBus.broadcast('group_publish', group, actor)
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
