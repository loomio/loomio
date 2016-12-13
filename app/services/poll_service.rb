class PollService
  def self.create(poll:, actor:, communities: [Communities::Public.new])
    actor.ability.authorize! :create, poll
    poll.assign_attributes(
      author:      actor,
      communities: communities,
      poll_options: PollOption.where(poll_template_id: poll.poll_template_id)
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
end
