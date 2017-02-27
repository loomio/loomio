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
    Events::PollCreated.publish!(poll)
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


  def self.close(poll:, actor:)
    actor.ability.authorize!(:close, poll)
    do_closing_work(poll: poll)
    EventBus.broadcast('poll_close', poll, actor)
    Events::PollClosedByUser.publish!(poll, actor)
  end

  def self.publish_closing_soon
    hour_start = 1.day.from_now.at_beginning_of_hour
    hour_finish = hour_start + 1.hour
    this_hour_tomorrow = hour_start..hour_finish
    Poll.closing_soon_not_published(this_hour_tomorrow).each do |poll|
      Events::PollClosingSoon.publish!(poll)
    end
  end

  def self.expire_lapsed_polls
    Poll.lapsed_but_not_closed.each do |poll|
      do_closing_work(poll: poll)
      EventBus.broadcast('poll_expire', poll)
      Events::PollExpired.publish!(poll)
    end
  end

  def self.do_closing_work(poll:)
    poll.update(closed_at: Time.now) unless poll.closed_at.present?
    # poll.poll_communities.for(:loomio_group).each do |poll_community|
    #   poll_community.update(community: poll_community.community.to_user_community)
    # end
    poll.poll_did_not_votes.delete_all
    non_voters = poll.group.members - poll.participants
    poll.poll_did_not_votes.import non_voters.map { |user| PollDidNotVote.new(user: user, poll: poll) }, validate: false
    poll.update_did_not_votes_count
  end


  def self.update(poll:, params:, actor:)
    actor.ability.authorize! :update, poll
    poll.assign_attributes(params.except(:poll_type, :discussion_id))

    return false unless poll.valid?
    poll.save!

    EventBus.broadcast('poll_update', poll, actor)
    Events::PollEdited.publish!(poll.versions.last, actor, poll.make_announcement)
  end

  def self.convert(motions:)
    # create a new poll from the motion
    Array(motions).map do |motion|
      next if motion.poll.present?
      # reference = PollReferences::Motion.new(motion)
      outcome = Outcome.new(statement: motion.outcome, author: motion.outcome_author) if motion.outcome.present?
      Poll.create!(
      # poll_references:   reference.references,
      # communities:       reference.communities,
        poll_type:               "proposal",
        poll_options_attributes: Poll::TEMPLATES.dig('proposal', 'poll_options_attributes'),
        discussion:              motion.discussion,
        motion:                  motion,
        title:                   motion.name,
        details:                 motion.description,
        author_id:               motion.author_id,
        created_at:              motion.created_at,
        updated_at:              motion.updated_at,
        closing_at:              motion.closing_at,
        closed_at:               motion.closed_at,
        outcomes:                Array(outcome)
      ).tap do |poll|
        poll.update(
          stances: motion.votes.map do |vote|
            stance = Stance.new(
              stance_choices:   [StanceChoice.new(poll_option: poll.poll_options.detect { |o| o.name == vote.position_verb })],
              participant_type: 'User',
              participant_id:   vote.user_id,
              reason:           vote.statement,
              latest:           vote.age.zero?,
              created_at:       vote.created_at,
              updated_at:       vote.updated_at
            )
          end
        )
        do_closing_work(poll: poll) if motion.closed?
        poll.update_stance_data
      end
    end
  end

end
