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

  def self.update(poll:, params:, actor:)
    actor.ability.authorize! :update, poll

    UserInviter.authorize!(user_ids: params[:recipient_user_ids],
                           emails: params[:recipient_emails],
                           audience: params[:recipient_audience],
                           model: poll,
                           actor: actor)

    poll.assign_attributes_and_files(params.except(:poll_type, :discussion_id, :group_id))

    return false unless poll.valid?

    poll.save!
    poll.update_versions_count

    users = UserInviter.where_or_create!(actor: actor,
                                         user_ids: params[:recipient_user_ids],
                                         emails: params[:recipient_emails],
                                         audience: params[:recipient_audience],
                                         model: poll)

    EventBus.broadcast('poll_update', poll, actor)

    Events::PollEdited.publish!(poll: poll,
                                actor: actor,
                                recipient_user_ids: users.pluck(:id),
                                recipient_audience: params[:recipient_audience],
                                recipient_message: params[:recipient_message])
  end

  def self.invite(poll:, actor:, params:)
    UserInviter.authorize!(user_ids: params[:recipient_user_ids],
                           emails: params[:recipient_emails],
                           audience: params[:recipient_audience],
                           model: poll,
                           actor: actor)


    if poll.discussion
      DiscussionService.add_users(discussion: poll.discussion,
                                  actor: actor,
                                  user_ids: params[:recipient_user_ids],
                                  emails: params[:recipient_emails],
                                  audience: params[:recipient_audience])
    end

    stances = create_stances(poll: poll, actor: actor,
                             user_ids: params[:recipient_user_ids],
                             emails: params[:recipient_emails],
                             audience: params[:recipient_audience])

    Events::PollAnnounced.publish!(poll, actor, stances)
    stances
  end

  def self.remind(poll:, actor:, params:)
    actor.ability.authorize! :remind, poll

    users = UserInviter.where_existing(user_ids: params[:recipient_user_ids],
                                       audience: params[:recipient_audience],
                                       model: poll,
                                       actor: actor)

    Events::PollReminder.publish!(poll: poll,
                                  actor: actor,
                                  recipient_user_ids: users.pluck(:id),
                                  recipient_audience: params[:recipient_audience],
                                  recipient_message: params[:recipient_message])
  end

  def self.create_stances(poll:, actor:, user_ids: [], emails: [], audience: nil)
    # user_ids = poll.base_guest_audience_query.where('users.id': Array(user_ids)).pluck(:id)
    # audience_ids = AnnouncementService.audience_users(poll, audience).pluck('users.id')

    # filter user_ids from group or poll or discussion
    existing_voter_ids =  Stance.latest.where(poll_id: poll.id).pluck(:participant_id)


    users = UserInviter.where_or_create!(actor: actor,
                                         model: poll,
                                         user_ids: user_ids,
                                         audience: audience,
                                         emails: emails).where.not(id: existing_voter_ids)

    volumes = {}

    # if the user has chosen to mute the thread or group then mute the poll too, but dont subsribe
    if poll.discussion_id
      DiscussionReader.where(discussion_id: poll.discussion_id,
                             user_id: users.pluck(:id),
                             volume: 1).find_each do |dr|
        volumes[dr.user_id] = dr.volume
      end
    end

    if poll.group_id
      Membership.where(group_id: poll.group_id,
                       user_id: users.pluck(:id),
                       volume: 1).find_each do |m|
        volumes[m.user_id] = m.volume unless volumes.has_key? m.user_id
      end
    end

    new_stances = users.map do |user|
      Stance.new(participant: user,
                 poll: poll,
                 inviter: actor,
                 volume: volumes[user.id] || DiscussionReader.volumes[:normal],
                 latest: true,
                 reason_format: user.default_format)
    end

    Stance.where(poll_id: poll.id, participant_id: users.pluck(:id)).update_all(latest: false)
    Stance.import(new_stances, on_duplicate_key_ignore: true)

    poll.update_voters_count
    poll.update_undecided_voters_count
    poll.update_stance_data

    Stance.where(participant_id: users.pluck(:id), poll_id: poll.id, latest: true)
  end

  def self.discard(poll:, actor:)
    actor.ability.authorize!(:destroy, poll)

    poll.update(discarded_at: Time.now, discarded_by: actor.id)
    Event.where(kind: "stance_created", eventable_id: poll.stances.pluck(:id)).update_all(discussion_id: nil)
    poll.created_event.update!(user_id: nil, child_count: 0, pinned: false)
    MessageChannelService.publish_models([poll.created_event], scope: {current_user: actor, current_user_id: actor.id}, group_id: poll.group_id)
    poll.created_event
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
      next if poll.closed_at
      do_closing_work(poll: poll)
      EventBus.broadcast('poll_expire', poll)
      Events::PollExpired.publish!(poll)
    end
  end

  def self.do_closing_work(poll:)
    return if poll.closed_at
    poll.stances.update_all(participant_id: nil) if poll.anonymous
    poll.update(closed_at: Time.now)
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

  def self.cleanup_examples
    Poll.where(example: true).where('created_at < ?', 1.day.ago).destroy_all
  end

  def self.add_to_thread(poll:, params:, actor:)
    discussion = Discussion.find(params[:discussion_id])
    actor.ability.authorize! :update, poll
    actor.ability.authorize! :update, discussion
    ActiveRecord::Base.transaction do
      poll.update(discussion_id: discussion.id, group_id: discussion.group.id, stances_in_discussion: false)
      event = poll.created_event
      event.discussion_id = discussion.id
      event.parent_id = discussion.created_event.id
      event.pinned = true
      event.set_sequences
      event.save
      poll.created_event.update_sequence_info!
    end
    poll.created_event
  end

end
