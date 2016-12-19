class PollService
  def self.create(poll:, actor:, communities: [], reference: nil)
    reference = PollReferences::Base.for(reference)
    poll.assign_attributes(
      poll_references: reference.references,
      poll_options:    poll.poll_template.poll_options,
      communities:     (communities + reference.communities).uniq.presence || [Communities::Public.new],
      author:          actor
    )
    actor.ability.authorize! :create, poll

    return false unless poll.valid?
    poll.save!

    EventBus.broadcast('poll_create', poll, actor)
  end

  def self.close(poll:, actor: nil)
    actor.ability.authorize!(:close, poll) if actor

    poll.update(closed_at: Time.now)
    poll.poll_communities.for(:loomio_group).each do |poll_community|
      poll_community.update(community: poll_community.community.to_user_community)
    end

    EventBus.broadcast('poll_close', poll, actor)
  end

  def self.update(poll:, params:, actor:)
    actor.ability.authorize! :update, poll
    poll.assign_attributes(params)

    return false unless poll.valid?
    poll.save!

    EventBus.broadcast('poll_update', poll, actor)
  end

  def self.convert(motions:)
    template  = PollTemplate.motion_template
    options   = template.poll_options

    # create a new poll from the motion
    Array(motions).map do |motion|
      reference = PollReferences::Motion.new(motion)
      Poll.create(
        poll_template:     template,
        poll_options:      options,
        poll_references:   reference.references,
        communities:       reference.communities,
        name:              motion.name,
        description:       motion.description,
        author_id:         motion.author_id,
        outcome_author_id: motion.outcome_author_id,
        outcome:           motion.outcome,
        created_at:        motion.created_at,
        updated_at:        motion.updated_at,
        closing_at:        motion.closing_at,
        closed_at:         motion.closed_at,
        stances:           motion.votes.map do |vote|
          Stance.new(
            poll_option:      options.detect { |o| o.name == vote.position_verb },
            statement:        vote.statement,
            participant_type: 'User',
            participant_id:   vote.user_id,
            latest:           vote.age.zero?,
            created_at:       vote.created_at,
            updated_at:       vote.updated_at
          )
        end
      ) unless motion.polls.any? # don't duplicate polls from a motion
    end
  end

end
