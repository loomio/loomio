class PollService
  def self.create(poll:, actor:)
    actor.ability.authorize! :create, poll

    poll.assign_attributes(author: actor)
    poll.prioritise_poll_options!

    return false unless poll.valid?
    poll.save!

    Stance.create!(participant: actor, poll: poll, admin: true, reason_format: actor.default_format)
    poll.update_counts!
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

    poll.assign_attributes_and_files(params.except(:poll_type, :discussion_id))

    # check again, because the group id could be updated to a untrusted group
    actor.ability.authorize! :update, poll

    poll.prioritise_poll_options!

    return false unless poll.valid?

    poll.save!

    users = UserInviter.where_or_create!(actor: actor,
                                         user_ids: params[:recipient_user_ids],
                                         emails: params[:recipient_emails],
                                         audience: params[:recipient_audience],
                                         model: poll)

    EventBus.broadcast('poll_update', poll, actor)

    Events::PollEdited.publish!(poll: poll,
                                actor: actor,
                                recipient_user_ids: users.pluck(:id),
                                recipient_chatbot_ids: params[:recipient_chatbot_ids],
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

    # params[:notify_recipients] will often be nil/undefined, which means we do want to notify
    unless params[:notify_recipients] == false
      Events::PollAnnounced.publish!(poll: poll,
                                     actor: actor,
                                     stances: stances,
                                     recipient_user_ids: params[:recipient_user_ids],
                                     recipient_chatbot_ids: params[:recipient_chatbot_ids],
                                     recipient_audience: params[:recipient_audience],
                                     recipient_message:  params[:recipient_message] )
    end
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
                                  recipient_chatbot_ids: params[:recipient_chatbot_ids],
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

    reinvited_user_ids = Stance.revoked.where(poll_id: poll.id).
                                pluck(:participant_id) & users.pluck(:id)
    Stance.where(
      poll_id: poll.id,
      participant_id: reinvited_user_ids).each do |stance|
      stance.update(revoked_at: nil, inviter_id: actor.id)
    end

    new_stances = users.where.not(id: reinvited_user_ids).map do |user|
      Stance.new(participant: user,
                 poll: poll,
                 inviter: actor,
                 volume: volumes[user.id] || DiscussionReader.volumes[:normal],
                 latest: true,
                 reason_format: user.default_format,
                 created_at: Time.zone.now)
    end

    Stance.import(new_stances)

    poll.reset_latest_stances!
    poll.update_counts!

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
      CloseExpiredPollWorker.perform_async(poll.id)
    end
  end

  def self.do_closing_work(poll:)
    return if poll.closed_at
    poll.stances.update_all(participant_id: nil) if poll.anonymous
    if poll.discussion_id && poll.hide_results == 'until_closed'
      stance_ids = poll.stances.latest.reject(&:body_is_blank?).map(&:id)
      Event.where(kind: 'stance_created', eventable_id: stance_ids, discussion_id: nil).update_all(discussion_id: poll.discussion_id)
      EventService.repair_thread(poll.discussion_id)
    end
    poll.update_attribute(:closed_at, Time.now)
  end

  def self.add_options(poll:, params:, actor:)
    actor.ability.authorize! :add_options, poll
    option_names = Array(params[:poll_option_names]) - poll.poll_option_names
    poll.poll_option_names += option_names

    poll.prioritise_poll_options!
    return false unless poll.valid?
    poll.save!

    EventBus.broadcast('poll_add_options', poll, actor, params)
    Events::PollOptionAdded.publish!(poll, actor, option_names)
  end

  # def self.destroy(poll:, actor:)
  #   actor.ability.authorize! :destroy, poll
  #   poll.destroy
  #
  #   EventBus.broadcast('poll_destroy', poll, actor)
  # end

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

  def self.calculate_results(poll, poll_options)
    sorted_poll_options = case poll.poll_type
    when 'proposal', 'count', 'meeting'
      poll_options.sort_by {|o| o.priority }
    else
      poll_options.sort_by {|o| -(o.total_score)}
    end

    l = sorted_poll_options.each_with_index.map do |option, index|
      option_name = poll.poll_option_name_format == 'i18n' ? "poll_#{poll.poll_type}_options."+option.name : option.name
      {
        id: option.id,
        name: option_name,
        name_format: poll.poll_option_name_format,
        rank: index+1,
        score: option.total_score,
        score_percent: poll.total_score > 0 ? ((option.total_score.to_f / poll.total_score.to_f) * 100) : 0,
        max_score_percent: poll.total_score > 0 ? ((option.total_score.to_f / poll.stance_counts.max.to_f) * 100) : 0,
        voter_percent: poll.voters_count > 0 ? ((option.voter_count.to_f / poll.voters_count.to_f) * 100) : 0,
        average: option.average_score,
        voter_scores: option.voter_scores,
        voter_ids: option.voter_ids.shuffle.take(500),
        voter_count: option.voter_count,
        color: option.color
      }.with_indifferent_access.freeze
    end
    if poll.results_include_undecided
      l.push({
          id: 0,
          name: 'poll_common_votes_panel.undecided',
          name_format: 'i18n',
          rank: nil,
          score: 0,
          score_percent: 0,
          max_score_percent: 0,
          voter_percent: poll.voters_count > 0 ? (poll.undecided_voters_count.to_f / poll.voters_count.to_f * 100) : 0,
          average: 0,
          voter_scores: {},
          voter_ids: poll.undecided_voters.map(&:id).shuffle.take(500),
          voter_count: poll.undecided_voters_count,
          color: '#BBBBBB'
      }.with_indifferent_access.freeze)
    end
    l
  end
end
