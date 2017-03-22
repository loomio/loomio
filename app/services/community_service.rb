class CommunityService
  def self.create(community:, actor:)
    actor.ability.authorize! :create, community

    return unless community.valid?
    community.save!

    EventBus.broadcast('community_create', community, actor)
  end

  def self.update(community:, params:, actor:)
    actor.ability.authorize! :update, community

    community.assign_attributes(params.slice(:slack_team_name, :facebook_group_name))
    return unless community.valid?
    community.save!

    EventBus.broadcast('community_update', community, actor)
  end

  def self.add(community:, actor:, poll:)
    actor.ability.authorize! :update, poll

    poll.poll_communities.build(community: community)
    return unless poll.valid?
    poll.save!

    EventBus.broadcast('community_add', community, actor, poll)
  end

  def self.remove(community:, actor:, poll:)
    actor.ability.authorize! :update, poll

    pc = poll.poll_communities.find_by(community: community)
    return unless pc.present?
    pc.destroy

    EventBus.broadcast('community_remove', community, actor, poll)
  end

  def self.destroy(community:, actor:)
    actor.ability.authorize! :destroy, community

    community.destroy
    EventBus.broadcast('community_destroy', community, actor)
  end
end
