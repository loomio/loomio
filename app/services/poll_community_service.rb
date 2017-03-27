class PollCommunityService
  def self.create(poll_community:, actor:)
    actor.ability.authorize! :create, poll_community

    return unless poll_community.valid?
    poll_community.save!

    EventBus.broadcast('poll_community_create', poll_community, actor)
  end

  def self.destroy(poll_community:, actor:)
    actor.ability.authorize! :destroy, poll_community

    poll_community.destroy
    EventBus.broadcast('poll_community_destroy', poll_community, actor)
  end
end
