class PollService
  def self.create(poll:, actor:)
    # reference = PollReferences::Base.for(reference)
    actor.ability.authorize! :create, poll

    poll.assign_attributes(author: actor)
    # communities:     reference.communities.presence || [Communities::Public.new],
    # poll_references: reference.references,

    return false unless poll.valid?
    poll.save!

    EventBus.broadcast('poll_create', poll, actor)
  end

  # def self.set_communities(poll:, actor:, communities:)
  #   return false unless communities.any?
  #
  #   actor.ability.authorize! :set_communities, poll
  #   communities.each { |community| actor.ability.authorize! :poll, community }
  #
  #   poll.assign_attributes(communities: communities)
  #
  #   return false unless poll.valid?
  #   poll.save!
  #
  #   EventBus.broadcast('poll_set_communities', poll, actor)
  # end

  def self.close(poll:, actor: nil)
    actor.ability.authorize!(:close, poll) if actor

    poll.update(closed_at: Time.now)
    # poll.poll_communities.for(:loomio_group).each do |poll_community|
    #   poll_community.update(community: poll_community.community.to_user_community)
    # end
    poll.poll_did_not_votes.delete_all
    non_voters = poll.group.members - poll.voters
    poll.poll_did_not_votes.import non_voters.map { |user| PollDidNotVote.new(user: user, poll: poll) }, validate: false

    EventBus.broadcast('poll_close', poll, actor)
  end

  def self.update(poll:, params:, actor:)
    actor.ability.authorize! :update, poll
    poll.assign_attributes(params.slice(:name, :description, :closing_at))

    return false unless poll.valid?
    poll.save!

    EventBus.broadcast('poll_update', poll, actor)
  end

  def self.convert(motions:)
    poll_options = PollOption.for("proposal")

    # create a new poll from the motion
    Array(motions).map do |motion|
      next if motion.polls.any?
      # reference = PollReferences::Motion.new(motion)
      Poll.create!(
        poll_type:         "proposal",
        poll_options:      poll_options,
        graph_type:        "pie",
        # poll_references:   reference.references,
        # communities:       reference.communities,
        discussion:        motion.discussion,
        motion:            motion,
        title:             motion.name,
        details:           motion.description,
        author_id:         motion.author_id,
        created_at:        motion.created_at,
        updated_at:        motion.updated_at,
        closing_at:        motion.closing_at,
        closed_at:         motion.closed_at,
        stances:           motion.votes.map do |vote|
          Stance.new(
            poll_option:      poll_options.detect { |o| o.name == vote.position_verb },
            statement:        vote.statement,
            participant_type: 'User',
            participant_id:   vote.user_id,
            latest:           vote.age.zero?,
            created_at:       vote.created_at,
            updated_at:       vote.updated_at
          )
        end,
        outcome: (Outcome.new(statement: motion.outcome, author: motion.outcome_author) if motion.outcome)
      )
    end
  end

end
