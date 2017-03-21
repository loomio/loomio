class CommunityService
  def self.create(community:, actor:)
    actor.ability.authorize! :create, community

    return unless community.valid?
    community.save!

    EventBus.broadcast('community_create', community, actor)
  end

  def self.update(community:, params:, actor:)
    actor.ability.authorize! :update, community

    community.assign_attributes(params.slice(:slack_team_id, :facebook_group_id))
    return unless community.valid?
    community.save!

    EventBus.broadcast('community_update', community, actor)
  end
end
