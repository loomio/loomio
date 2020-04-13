class PollService
  def self.create(poll:, actor:)
    actor.ability.authorize! :create, poll

    poll.assign_attributes(author: actor)

    return false unless poll.valid?
    poll.save!

    Stance.create!(participant: actor, poll: poll, admin: true, reason_format: actor.default_format)
    EventBus.broadcast('poll_create', poll, actor)
    Events::PollCreated.publish!(poll, actor)
  end

  def self.announce(poll:, actor:, params:)
    actor.ability.authorize! :announce, poll

    users = UserInviter.where_or_create!(inviter: actor,
                                         emails: params[:emails],
                                         user_ids: params[:user_ids])

    new_stances =  users.map do |user|
      Stance.new(participant: user, poll: poll, inviter: actor, volume: DiscussionReader.volumes[:normal], reason_format: user.default_format)
    end
    Stance.import(new_stances, on_duplicate_key_ignore: true)

    if poll.discussion
      new_discussion_readers = users.map do |user|
        DiscussionReader.new(user: user, discussion: poll.discussion, inviter: actor, volume: DiscussionReader.volumes[:normal])
      end

      DiscussionReader.import(new_discussion_readers, on_duplicate_key_ignore: true)
    end


    stances = Stance.where(participant_id: users.pluck(:id), poll: poll)
    poll.update_stances_count
    poll.update_undecided_count
    poll.update_stance_data

    Events::PollAnnounced.publish!(poll, actor, stances)
    stances
  end

  def self.close(poll:, actor:)
    actor.ability.authorize! :close, poll
    do_closing_work(poll: poll)
    EventBus.broadcast('poll_close', poll, actor)
    Events::PollClosedByUser.publish!(poll, actor)
  end

  def self.reopen(poll:, params:, actor:)
    actor.ability.authorize! :reopen, poll

    poll.assign_attributes(closing_at: params[:closing_at], closed_at: nil)
    return false unless poll.valid?

    poll.save!

    EventBus.broadcast('poll_reopen', poll, actor)
    Events::PollReopened.publish!(poll, actor)
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
  end

  def self.update(poll:, params:, actor:)
    actor.ability.authorize! :update, poll
    HasRichText.assign_attributes_and_update_files(poll, params.except(:poll_type, :discussion_id))
    is_new_version = poll.is_new_version?

    return false unless poll.valid?
    poll.save!

    EventBus.broadcast('poll_update', poll, actor)
    Events::PollEdited.publish!(poll, actor) if is_new_version
  end

  def self.add_options(poll:, params:, actor:)
    actor.ability.authorize! :add_options, poll
    option_names = Array(params[:poll_option_names]) - poll.poll_option_names
    poll.poll_option_names += option_names

    return false unless poll.valid?
    poll.save!

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

  def self.cleanup_examples
    Poll.where(example: true).where('created_at < ?', 1.day.ago).destroy_all
  end

end
