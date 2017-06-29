class PollService
  def self.create(poll:, actor:)
    actor.ability.authorize! :create, poll

    poll.assign_attributes(author: actor)

    return false unless poll.valid?
    poll.create_guest_group.add_admin!(actor)
    poll.save!

    EventBus.broadcast('poll_create', poll, actor)
    Events::PollCreated.publish!(poll, actor)
  end

  def self.close(poll:, actor:)
    actor.ability.authorize! :close, poll
    do_closing_work(poll: poll)
    EventBus.broadcast('poll_close', poll, actor)
    Events::PollClosedByUser.publish!(poll, actor)
  end

  def self.publish(poll:, params:, actor:)
    community = Communities::Base.find(params[:community_id])
    actor.ability.authorize! :show, community
    actor.ability.authorize! :share, poll

    EventBus.broadcast('poll_publish', poll, actor, community, params[:message])
    Events::PollPublished.publish!(poll, actor, community, params[:message])
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
    poll.poll_did_not_votes.delete_all
    non_voters = poll.members - poll.participants
    poll.poll_did_not_votes.import non_voters.map { |user| PollDidNotVote.new(user: user, poll: poll) }, validate: false
    poll.update_undecided_user_count
  end

  def self.update(poll:, params:, actor:)
    actor.ability.authorize! :update, poll
    poll.assign_attributes(params.except(:poll_type, :discussion_id, :communities_attributes))
    is_new_version = poll.is_new_version?

    return false unless poll.valid?
    poll.build_loomio_group_community if poll.changes.keys.include?('group_id')
    poll.save!

    EventBus.broadcast('poll_update', poll, actor)
    Events::PollEdited.publish!(poll.versions.last, actor, poll.make_announcement) if is_new_version
  end

  def self.add_options(poll:, params:, actor:)
    actor.ability.authorize! :add_options, poll
    option_names = Array(params[:poll_option_names]) - poll.poll_option_names
    poll.poll_option_names += option_names

    return false unless poll.valid?
    poll.save!

    poll.make_announcement = true # TODO: handle announcements (or not?) for add options
    EventBus.broadcast('poll_add_options', poll, actor, params)
    Events::PollOptionAdded.publish!(poll, actor, option_names)
  end

  def self.destroy(poll:, actor:)
    actor.ability.authorize! :destroy, poll
    poll.destroy

    EventBus.broadcast('poll_destroy', poll, actor)
  end

  def self.toggle_subscription(poll:, actor:)
    actor.ability.authorize! :toggle_subscription, poll

    unsubscription = poll.poll_unsubscriptions.find_or_initialize_by(user: actor)
    if unsubscription.persisted?
      unsubscription.destroy
    else
      unsubscription.save!
    end

    EventBus.broadcast('poll_toggle_subscription', poll, actor)
  end

  def self.create_visitors(poll:, emails:, actor:)
    actor.ability.authorize! :create_visitors, poll

    VisitorsBatchCreateJob.perform_later(emails, poll.id, actor.id)
    poll.pending_emails = []
    poll.save(validate: false)

    EventBus.broadcast('poll_create_visitors', poll, emails, actor)
  end

  def self.convert(motions:)
    # create a new poll from the motion
    Array(motions).map do |motion|
      next if motion.poll.present?
      outcome = Outcome.new(statement: motion.outcome, author: motion.outcome_author) if motion.outcome.present?

      # convert motion to poll
      poll = Poll.new(
        poll_type:               "proposal",
        poll_options_attributes: AppConfig.poll_templates.dig('proposal', 'poll_options_attributes'),
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
      poll.community_of_type(:email, build: true)
      poll.build_loomio_group_community
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
    end
  end

  def self.convert_visitors(poll: poll)
    poll.create_guest_group
    poll.visitors.each do |visitor|
      user = User.find_or_initialize_by(email: visitor.email)
      if user.persisted?
        poll.guest_group.add_member!(user)
        poll.stances.where(participant: visitor).update_all(participant_id: user.id, participant_type: "User")
      else
        poll.guest_group.invitations.create!(recipient_email: visitor.email,
        recipient_name: visitor.name,
        token: visitor.participation_token,
        intent: "join_group")
      end
    end

    do_closing_work(poll: poll) if poll.closed?
  end

  def self.cleanup_examples
    Poll.where(example: true).where('created_at < ?', 1.day.ago).destroy_all
  end

end
