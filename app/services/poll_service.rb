class PollService
  def self.create(poll:, actor:)
    actor.ability.authorize! :create, poll

    poll.assign_attributes(author: actor)

    return false unless poll.valid?
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
    is_new_group   = params.has_key?(:group_id) && params[:group_id] != poll.group_id
    poll.assign_attributes(params.except(:poll_type, :discussion_id))
    is_new_version = poll.is_new_version?

    return false unless poll.valid?
    poll.save!

    EventBus.broadcast('poll_update', poll, actor)
    EventBus.broadcast('poll_changed_group', poll, actor)                          if is_new_group
    Events::PollEdited.publish!(poll, actor, poll.make_announcement) if is_new_version
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

  def self.invite_guests(poll:, emails:, actor:)
    actor.ability.authorize! :create_visitors, poll

    VisitorsBatchCreateJob.perform_later(emails, poll.id, actor.id)
    poll.pending_emails = []
    poll.save(validate: false)

    EventBus.broadcast('poll_create_visitors', poll, emails, actor)
  end

  def self.cleanup_examples
    Poll.where(example: true).where('created_at < ?', 1.day.ago).destroy_all
  end

end
