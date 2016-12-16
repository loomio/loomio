class PollService
  def self.create(poll:, actor:, communities: [], parent: nil)
    poll.communities = apply_communities(communities: communities, parent: parent)
    actor.ability.authorize! :create, poll

    poll.assign_attributes(
      author:           actor,
      poll_options:     PollOption.where(poll_template_id: poll.poll_template_id)
    )

    return false unless poll.valid?
    poll.save!

    EventBus.broadcast('poll_create', poll, actor)
  end

  def self.update(poll:, params:, actor:)
    actor.ability.authorize! :update, poll
    poll.assign_attributes(params)

    return false unless poll.valid?
    poll.save!

    EventBus.broadcast('poll_update', poll, actor)
  end

  def self.apply_communities(communities:, parent:)
    communities << parent&.community
    communities << parent.group&.community if parent.respond_to?(:group)
    communities.compact.uniq.presence || [Communities::Public.new]
  end
end
