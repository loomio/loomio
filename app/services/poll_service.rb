class PollService
  def self.build(params:, actor:)
    params = params.to_h.with_indifferent_access
    topic_params = params.extract!(*DiscussionService::TOPIC_ATTRS)

    poll = Poll.new
    poll.assign_attributes_and_files(params)
    poll.author = actor
    poll.prioritise_poll_options!

    poll.topic ||= Topic.new(
                     topicable: poll,
                     group_id: topic_params[:group_id],
                     private: topic_params.key?(:private) ? topic_params[:private] : true,
                    )

    if !poll.opened_at &&
        poll.closing_at &&
        (poll.opening_at.blank? || poll.opening_at <= Time.now)
      poll.opened_at = Time.now
    end

    poll
  end

  def self.create(params:, actor:)
    poll = build(params: params, actor: actor)

    Poll.transaction do
      actor.ability.authorize!(:create, poll)

      poll.save!
      poll.update_counts!
      create_anyone_can_vote_stances(poll) if !poll.specified_voters_only

      TopicReader.for(user: actor, topic: poll.topic)
                  .update(admin: true, guest: !poll.topic.group_id.present?, inviter_id: actor.id)

      EventBus.broadcast('poll_create', poll, actor)
      event = Events::PollCreated.publish!(poll, actor)
      announce_poll_opened(poll) if poll.opened_at && poll.notify_on_open
      poll
    end
  end

  def self.update(poll:, params:, actor:)
    actor.ability.authorize! :update, poll

    UserInviter.authorize!(
      user_ids: params[:recipient_user_ids],
      emails: params[:recipient_emails],
      audience: params[:recipient_audience],
      model: poll,
      actor: actor
    )
    poll.assign_attributes_and_files(params.except(:poll_type, :poll_template_id, :poll_template_key))

    # check again, because the group id could be updated to a untrusted group
    actor.ability.authorize! :update, poll

    poll.prioritise_poll_options!

    return false unless poll.valid?

    Poll.transaction do
      poll.save!
      poll.update_counts!

      open_poll_if_ready(poll)

      GenericWorker.perform_async('SearchService', 'reindex_by_poll_id', poll.id)

      GenericWorker.perform_async('PollService', 'group_members_added', poll.group_id) if poll.group_id

      users = UserInviter.where_or_create!(
        actor: actor,
        user_ids: params[:recipient_user_ids],
        emails: params[:recipient_emails],
        audience: params[:recipient_audience],
        model: poll
      )

      EventBus.broadcast('poll_update', poll, actor)

      Events::PollEdited.publish!(
        poll: poll,
        actor: actor,
        recipient_user_ids: users.pluck(:id),
        recipient_chatbot_ids: params[:recipient_chatbot_ids],
        recipient_audience: params[:recipient_audience],
        recipient_message: params[:recipient_message]
      )
    end
  end

  def self.invite(poll:, actor:, params:)
    UserInviter.authorize!(
      user_ids: params[:recipient_user_ids],
      emails: params[:recipient_emails],
      audience: params[:recipient_audience],
      model: poll,
      actor: actor,
    )

    stances = nil

    Poll.transaction do
      TopicService.add_users(
        topic:  poll.topic,
        actor: actor,
        user_ids: params[:recipient_user_ids],
        emails: params[:recipient_emails],
        audience: params[:recipient_audience],
      )

      stances = create_stances(
        poll: poll, actor: actor,
        user_ids: params[:recipient_user_ids],
        emails: params[:recipient_emails],
        include_actor: params[:include_actor],
        audience: params[:recipient_audience]
      )

      if params[:notify_recipients]
        Events::PollAnnounced.publish!(
          poll: poll,
          actor: actor,
          stances: stances,
          recipient_user_ids: params[:recipient_user_ids],
          recipient_chatbot_ids: params[:recipient_chatbot_ids],
          recipient_audience: params[:recipient_audience],
          recipient_message:  params[:recipient_message],
        )
      end
    end

    stances
  end

  def self.remind(poll:, actor:, params:)
    actor.ability.authorize! :remind, poll

    Poll.transaction do
      users = UserInviter.where_existing(
        user_ids: params[:recipient_user_ids],
        audience: params[:recipient_audience],
        model: poll,
        actor: actor
      )

      Events::PollReminder.publish!(
        poll: poll,
        actor: actor,
        recipient_user_ids: users.pluck(:id),
        recipient_chatbot_ids: params[:recipient_chatbot_ids],
        recipient_audience: params[:recipient_audience],
        recipient_message: params[:recipient_message]
      )
    end
  end

  def self.create_stances(poll:, actor:, user_ids: [], emails: [], audience: nil, include_actor: false)
    existing_voter_ids = Stance.latest.where(poll_id: poll.id).pluck(:participant_id)

    users = UserInviter.where_or_create!(
      actor: actor,
      model: poll,
      user_ids: user_ids,
      audience: audience,
      include_actor: include_actor,
      emails: emails
    ).where.not(id: existing_voter_ids)

    reinvited_user_ids = Stance.revoked.where(poll_id: poll.id).pluck(:participant_id) & users.pluck(:id)

    Stance.where(poll_id: poll.id, participant_id: reinvited_user_ids).each do |stance|
      stance.update(revoked_at: nil, revoker_id: nil, inviter_id: actor.id)
    end

    new_stances = users.where.not(id: reinvited_user_ids).map do |user|
      Stance.new(
        participant: user,
        poll: poll,
        inviter: actor,
        latest: true,
        reason_format: user.default_format,
        created_at: Time.zone.now
      )
    end

    Stance.import(new_stances, on_duplicate_key_ignore: true)

    poll.reset_latest_stances!
    poll.update_counts!

    Stance.where(participant_id: users.pluck(:id), poll_id: poll.id, latest: true)
  end

  def self.discard(poll:, actor:)
    actor.ability.authorize!(:destroy, poll)

    Poll.transaction do
      poll.update(discarded_at: Time.now, discarded_by: actor.id)
      Event.where(kind: ["stance_created", "stance_updated"], eventable_id: poll.stances.pluck(:id)).update_all(topic_id: nil)
      poll.created_event.update!(user_id: nil, child_count: 0, pinned: false)
      poll.topic.update_sequence_info!
    end

    MessageChannelService.publish_models([poll.created_event], scope: {current_user: actor, current_user_id: actor.id}, group_id: poll.group_id)
    poll.created_event
  end

  def self.close(poll:, actor:)
    actor.ability.authorize! :close, poll
    Poll.transaction do
      do_closing_work(poll: poll)
      Events::PollClosedByUser.publish!(poll, actor)
    end
  end

  def self.reopen(poll:, params:, actor:)
    actor.ability.authorize! :reopen, poll

    poll.assign_attributes(closing_at: params[:closing_at], closed_at: nil, opening_at: nil, opened_at: Time.now)
    return false unless poll.valid?

    Poll.transaction do
      poll.save!

      EventBus.broadcast('poll_reopen', poll, actor)
      Events::PollReopened.publish!(poll, actor)
      announce_poll_opened(poll) if poll.notify_on_open
    end
  end

  def self.publish_closing_soon
    hour_start = 1.day.from_now.at_beginning_of_hour
    hour_finish = hour_start + 1.hour
    this_hour_tomorrow = hour_start..hour_finish
    Poll.closing_soon_not_published(this_hour_tomorrow).each do |poll|
      Events::PollClosingSoon.publish!(poll)
    end
  end

  def self.open_scheduled_polls
    Poll.kept
        .where(opened_at: nil)
        .where("opening_at IS NOT NULL AND opening_at <= ?", Time.now)
        .each { |poll| open_poll_if_ready(poll) }
  end

  def self.group_members_added(group_id)
    return if group_id.nil?

    Poll.active.joins(:topic).where(topics: { group_id: group_id }, specified_voters_only: false).each do |poll|
      create_anyone_can_vote_stances(poll)
    end
  end

  def self.create_anyone_can_vote_stances(poll)
    raise "only use on specified_voters_only=false" if poll.specified_voters_only

    member_ids = poll.members.humans.pluck(:id).uniq
    revoked_user_ids = poll.stances.revoked.pluck(:participant_id).uniq

    create_stances(
      poll: poll,
      actor: poll.author,
      user_ids: (member_ids - poll.voter_ids) - revoked_user_ids
    )
  end

  def self.group_members_removed(group_id, removed_user_ids, actor_id, revoked_at)
    Poll.active.joins(:topic).where(topics: { group_id: group_id }).each do |poll|
      Stance.where(
        poll_id: poll.id,
        revoked_at: nil,
        participant_id: Array(removed_user_ids),
      ).update_all(revoked_at: revoked_at, revoker_id: actor_id)
      poll.update_counts!
    end
  end

  def self.expire_lapsed_polls
    Poll.lapsed_but_not_closed.each do |poll|
      CloseExpiredPollWorker.perform_async(poll.id)
    end
  end

  def self.do_closing_work(poll:)
    return if poll.closed_at

    StanceReceipt.where(poll_id: poll.id).delete_all
    StanceReceipt.insert_all build_receipts(poll)

    poll.stances.update_all(participant_id: nil) if poll.anonymous

    if poll.topic && poll.hide_results == 'until_closed'
      stance_ids = poll.stances.latest.reject(&:body_is_blank?).map(&:id)
      Event.where(kind: 'stance_created', eventable_id: stance_ids, topic_id: nil).update_all(topic_id: poll.topic.id)
      TopicService.repair_thread(poll.topic_id)
    end

    poll.update_attribute(:closed_at, Time.now)
    GenericWorker.perform_async('SearchService', 'reindex_by_poll_id', poll.id)
  end

  def self.build_receipts(poll)
    return [] if poll.anonymous && poll.closed_at

    poll.stances.latest.map do |stance|
      {
        poll_id: poll.id,
        voter_id: stance.participant_id,
        inviter_id: stance.inviter_id,
        invited_at: stance.created_at,
        vote_cast: (!poll.anonymous? || poll.quorum_reached?) ? !!stance.cast_at : nil
      }
    end
  end

  # def self.destroy(poll:, actor:)
  #   actor.ability.authorize! :destroy, poll
  #   poll.destroy
  #
  #   EventBus.broadcast('poll_destroy', poll, actor)
  # end

  def self.add_to_thread(poll:, params:, actor:)
    discussion = Discussion.find(params[:discussion_id])
    actor.ability.authorize! :update, poll
    actor.ability.authorize! :update, discussion
    ActiveRecord::Base.transaction do
      old_topic = poll.topic if poll.topic&.topicable_type == 'Poll'
      poll.update(topic_id: discussion.topic_id)
      old_topic&.destroy
      event = poll.created_event
      event.topic_id = discussion.topic.id
      event.parent_id = discussion.created_event.id
      event.pinned = true
      event.set_sequences
      event.save
      discussion.update_sequence_info!
    end

    if (poll.closed? || poll.hide_results != 'until_closed')
      stance_ids = poll.stances.latest.reject(&:body_is_blank?).map(&:id)
      Event.where(kind: 'stance_created', eventable_id: stance_ids).update_all(topic_id: discussion.topic.id)
      TopicService.repair_thread(discussion.topic_id)
    end

    GenericWorker.perform_async('SearchService', 'reindex_by_discussion_id', discussion.id)

    poll.created_event
  end

  def self.calculate_results(poll, poll_options)
    sorted_poll_options = case poll.order_results_by
    when 'priority'
      poll_options.sort_by {|o| o.priority }
    else
      # when 'total_score_desc'
      poll_options.sort_by {|o| -(o.total_score)}
    end

    l = sorted_poll_options.each_with_index.map do |option, index|
      option_name = poll.poll_option_name_format == 'i18n' ? "poll_#{poll.poll_type}_options."+option.name : option.name
      score_percent = poll.total_score > 0 ? ((option.total_score.to_f / poll.total_score.to_f) * 100) : 0
      voter_percent = poll.voters_count > 0 ? ((option.voter_count.to_f / poll.voters_count.to_f) * 100) : 0

      test_result = if option.test_operator == 'gte'
        if option.test_against == 'score_percent'
          score_percent >= option.test_percent.to_f
        else
          voter_percent >= option.test_percent.to_f
        end
      elsif option.test_operator == 'lte'
        if option.test_against == 'score_percent'
          score_percent <= option.test_percent.to_f
        else
          voter_percent <= option.test_percent.to_f
        end
      else
        nil
      end

      {
        id: option.id,
        poll_id: option.poll_id,
        name: option_name,
        name_format: poll.poll_option_name_format,
        icon: option.icon,
        rank: index+1,
        score: option.total_score,
        target_percent: ((option.icon == 'agree') && (poll.agree_target.to_i > 0)) ? ((option.total_score.to_f / poll.agree_target.to_f) * 100) : 0,
        score_percent: score_percent,
        max_score_percent: poll.total_score > 0 ? ((option.total_score.to_f / poll.stance_counts.max.to_f) * 100) : 0,
        voter_percent: voter_percent,
        average: option.average_score,
        voter_scores: option.voter_scores,
        voter_ids: option.voter_ids.take(500),
        voter_count: option.voter_count,
        color: option.color,
        test_operator: option.test_operator,
        test_against: option.test_against,
        test_percent: option.test_percent,
        test_result: test_result
      }.with_indifferent_access.freeze
    end

    if poll.show_none_of_the_above
      l.push(
        {
          id: 0,
          poll_id: poll.id,
          name: 'poll_common_form.none_of_the_above',
          name_format: 'i18n',
          rank: nil,
          score: 0,
          score_percent: 0,
          max_score_percent: 0,
          target_percent: poll.voters_count > 0 ? (poll.none_of_the_above_count.to_f / poll.voters_count.to_f * 100) : 0,
          voter_percent: poll.voters_count > 0 ? (poll.none_of_the_above_count.to_f / poll.voters_count.to_f * 100) : 0,
          average: 0,
          voter_scores: {},
          voter_ids: poll.none_of_the_above_voters.map(&:id).take(500),
          voter_count: poll.none_of_the_above_count,
          color: '#BBBBBB',
          test_result: nil
        }.with_indifferent_access.freeze
      )
    end

    if poll.results_include_undecided
      l.push(
        {
          id: -1,
          poll_id: poll.id,
          name: 'poll_common_votes_panel.undecided',
          name_format: 'i18n',
          rank: nil,
          score: 0,
          score_percent: nil,
          max_score_percent: 0,
          target_percent: poll.voters_count > 0 ? (poll.undecided_voters_count.to_f / poll.voters_count.to_f * 100) : 0,
          voter_percent: poll.voters_count > 0 ? (poll.undecided_voters_count.to_f / poll.voters_count.to_f * 100) : 0,
          average: 0,
          voter_scores: {},
          voter_ids: poll.undecided_voters.map(&:id).take(500),
          voter_count: poll.undecided_voters_count,
          color: '#BBBBBB',
          test_result: nil
        }.with_indifferent_access.freeze
      )
    end
    l
  end

  def self.open_poll_if_ready(poll)
    return if poll.opened_at
    return unless poll.closing_at
    return if poll.opening_at.present? && poll.opening_at > Time.now

    poll.update_column(:opened_at, Time.now)
    announce_poll_opened(poll) if poll.notify_on_open
  end

  def self.announce_poll_opened(poll)
    stances = poll.stances.latest.where.not(participant_id: poll.author_id)
    return if stances.empty?

    Events::PollAnnounced.publish!(
      poll: poll,
      actor: poll.author,
      stances: stances
    )
  end
end
