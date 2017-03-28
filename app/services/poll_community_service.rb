class PollCommunityService
  def self.destroy(poll_community:, actor:)
    actor.ability.authorize! :destroy, poll_community

    poll_community.destroy
    EventBus.broadcast('poll_community_destroy', poll_community, actor)
  end
end
