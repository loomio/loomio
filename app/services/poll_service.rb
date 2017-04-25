class PollService
  def self.create(poll:, actor:)
    actor.ability.authorize! :create, poll

    poll.assign_attributes(author: actor)
    poll.community_of_type(:email, build: true)
    poll.community_of_type(:public, build: true)

    return false unless poll.valid?
    poll.save!

    EventBus.broadcast('poll_create', poll, actor)
    Events::PollCreated.publish!(poll)
  end

  def self.close(poll:, actor:)
    actor.ability.authorize! :close, poll
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
    poll.poll_communities.for(:loomio_group).each do |poll_community|
      poll_community.update(community: poll_community.community.to_user_community)
    end

    return unless poll.group
    poll.poll_did_not_votes.delete_all
    non_voters = poll.group.members - poll.participants
    poll.poll_did_not_votes.import non_voters.map { |user| PollDidNotVote.new(user: user, poll: poll) }, validate: false
    poll.update_did_not_votes_count
  end

  def self.update(poll:, params:, actor:)
    actor.ability.authorize! :update, poll
    poll.assign_attributes(params.except(:poll_type, :discussion_id, :communities_attributes))

    return false unless poll.valid?
    poll.save!

    EventBus.broadcast('poll_update', poll, actor)
    Events::PollEdited.publish!(poll.versions.last, actor, poll.make_announcement)
  end

  def self.convert(motions:)
    # create a new poll from the motion
    Array(motions).map do |motion|
      next if motion.poll.present?
      outcome = Outcome.new(statement: motion.outcome, author: motion.outcome_author) if motion.outcome.present?

      # convert motion to poll
      poll = Poll.new(
        poll_type:               "proposal",
        poll_options_attributes: Poll::TEMPLATES.dig('proposal', 'poll_options_attributes'),
        key:                     motion.key,
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
      )
      poll.save(validate: false)

      # convert votes to stances
      poll.update(
        stances: motion.votes.map do |vote|
          stance_choice = StanceChoice.new(poll_option: poll.poll_options.detect { |o| o.name == vote.position_verb })
          Stance.new(
            participant_type: 'User',
            participant_id:   vote.user_id,
            reason:           vote.statement,
            latest:           vote.age.zero?,
            created_at:       vote.created_at,
            updated_at:       vote.updated_at,
            stance_choices:   Array(stance_choice)
          )
        end
      )
      poll.update_stance_data

      # set poll to closed if motion was closed
      do_closing_work(poll: poll) if motion.closed?

      # add communities
      poll.communities << Communities::Email.new
    end
  end

end
