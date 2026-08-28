class PollService
  def self.build(params:, actor:)
    params = params.to_h.with_indifferent_access
    topic_params = params.extract!(*DiscussionService::TOPIC_ATTRS)

    poll = Poll.new
    poll.assign_attributes_and_files(params)
    if poll.anonymous?
      poll.voting_system = :anonymous_ballot
      poll.hide_results = :until_closed
      poll.stance_reason_required = :disabled
      poll.notify_on_closing_soon = :undecided_voters
    end
    poll.author = actor
    poll.prioritise_poll_options!

    # When private isn't explicitly sent (polls don't surface a privacy toggle),
    # derive it from the group's discussion_privacy_options so we don't create
    # a private topic in a group that only allows public threads.
    unless topic_params.key?(:private)
      gid = topic_params[:group_id]
      gid ||= poll.topic.group_id if poll.topic
      topic_params[:private] = TopicService.private_default(group_id: gid)
    end

    poll.topic ||= Topic.new topic_params.merge(topicable: poll)

    if !poll.opened_at &&
        poll.closing_at &&
        (poll.opening_at.blank? || poll.opening_at <= Time.now)
      poll.opened_at = Time.now
    end

    poll
  end

  def self.create(params:, actor:, &on_topic_item)
    poll = build(params: params, actor: actor)
    actor.ability.authorize!(:create, poll)
    TagService.authorize_create_tag_names!(poll.group, poll.topic.tags, actor)
    return poll unless TopicService.validate_topicable(poll)

    topic_item = Poll.transaction do
      poll.save!
      if poll.detached_anonymous?
        create_anonymous_poll_voters(poll: poll, actor: actor, params: params)
      else
        create_anyone_can_vote_stances(poll) if !poll.specified_voters_only
      end
      poll.update_counts!

      TopicReader.for(user: actor, topic: poll.topic)
                  .update(admin: true, guest: !poll.topic.group_id.present?, inviter_id: actor.id)

      Sentry.metrics.count("poll.create", attributes: { poll_type: poll.poll_type })
      topic_item = TopicItems::PollCreated.create!(
        itemable: poll,
        pinned: true
      )
      MentionNotificationService.create!(
        subject: topic_item,
        actor: actor
      )
      announce_poll_opened(poll) if poll.opened_at && poll.notify_on_open
      topic_item
    end
    EventBus.broadcast('poll_create', poll, actor)
    publish_topic_if_active(poll) if poll.opened_at
    on_topic_item&.call(topic_item)
    poll
  end

  def self.update(poll:, params:, actor:, &on_topic_item)
    actor.ability.authorize! :update, poll
    UserInviter.authorize!(
      user_ids: params[:recipient_user_ids],
      emails: params[:recipient_emails],
      audience: params[:recipient_audience],
      model: poll,
      actor: actor
    )
    params = params.to_h.with_indifferent_access
    topic_params = params.extract!(*DiscussionService::TOPIC_ATTRS).slice(*DiscussionService::TOPIC_ATTRS_UPDATE)
    poll.assign_attributes_and_files(params.except(:poll_type, :poll_template_id, :poll_template_key))

    # check again, because the group id could be updated to a untrusted group
    actor.ability.authorize! :update, poll

    poll.prioritise_poll_options!

    unless poll.valid?
      Sentry.metrics.count("poll.update_failed", attributes: { columns: poll.errors.attribute_names.join(',') })
      return poll
    end

    was_opened = false
    topic_item = Poll.transaction do
      poll.topic.update!(topic_params) if topic_params.any? && poll.topic.persisted?
      poll.save!
      poll.update_counts!

      was_opened = open_poll_if_ready(poll)

      ReindexPollWorker.perform_later(poll.id)

      PollGroupMembersAddedWorker.perform_later(poll.group_id) if poll.group_id

      users = UserInviter.where_or_create!(
        actor: actor,
        user_ids: params[:recipient_user_ids],
        emails: params[:recipient_emails],
        audience: params[:recipient_audience],
        model: poll
      )

      mention_audience = {
        newly_mentioned_user_ids: poll.newly_mentioned_users.pluck(:id),
        mentioned_user_ids: poll.mentioned_users.pluck(:id),
        mentioned_group_user_ids: poll.mentioned_group_users.pluck(:id)
      }

      Sentry.metrics.count("poll.update", attributes: { poll_type: poll.poll_type })

      if params[:recipient_message].present?
        topic_item = TopicItems::PollEdited.create!(
          itemable: poll,
          user: actor
        )
      end
      if topic_item || users.any? || Array(params[:recipient_chatbot_ids]).compact.any?
        NotificationService.create!(
          kind: "poll_edited",
          subject: topic_item || poll,
          actor: actor,
          recipient_user_ids: users.pluck(:id),
          recipient_chatbot_ids: params[:recipient_chatbot_ids],
          recipient_message: params[:recipient_message],
          audience_values: mention_audience
        )
      end
      MentionNotificationService.create!(
        subject: topic_item || poll,
        actor: actor,
        already_notified_user_ids: users.pluck(:id)
      )
      topic_item
    end
    EventBus.broadcast('poll_update', poll, actor)
    MessageChannelService.publish_topic_model(poll) unless topic_item
    publish_topic_if_active(poll) if was_opened
    on_topic_item&.call(topic_item) if topic_item
    poll
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
    voters = nil

    Poll.transaction do
      poll.lock!
      raise CanCan::AccessDenied if poll.detached_anonymous? && !poll.active?

      TopicService.add_users(
        topic:  poll.topic,
        actor: actor,
        user_ids: params[:recipient_user_ids],
        emails: params[:recipient_emails],
        audience: params[:recipient_audience],
      )

      if poll.detached_anonymous?
        voters = create_anonymous_poll_voters(poll: poll, actor: actor, params: params)
        poll.update_counts!
      else
        stances = create_stances(
          poll: poll, actor: actor,
          user_ids: params[:recipient_user_ids],
          emails: params[:recipient_emails],
          include_actor: params[:include_actor],
          audience: params[:recipient_audience]
        )
      end

      if params[:notify_recipients] && !poll.detached_anonymous?
        create_poll_announced_notification!(
          poll: poll,
          actor: actor,
          stances: stances,
          recipient_user_ids: params[:recipient_user_ids],
          recipient_chatbot_ids: params[:recipient_chatbot_ids],
          recipient_audience: params[:recipient_audience],
          recipient_message:  params[:recipient_message],
        )
      elsif params[:notify_recipients] && poll.detached_anonymous? && voters.any?
        create_poll_announced_notification!(
          poll: poll,
          actor: actor,
          stances: [],
          recipient_user_ids: voters.pluck(:voter_id),
          recipient_chatbot_ids: [],
          recipient_audience: nil,
          recipient_message: params[:recipient_message]
        )
      end
    end

    poll.detached_anonymous? ? voters : stances
  end

  def self.create_anonymous_poll_voters(poll:, actor:, params:)
    users = if poll.specified_voters_only?
      UserInviter.authorize!(
        user_ids: params[:recipient_user_ids],
        emails: params[:recipient_emails],
        audience: params[:recipient_audience],
        model: poll,
        actor: actor
      )
      UserInviter.where_or_create!(
        actor: actor,
        model: poll,
        user_ids: params[:recipient_user_ids],
        emails: params[:recipient_emails],
        audience: params[:recipient_audience]
      )
    else
      poll.members.humans
    end

    existing_voter_ids = poll.anonymous_poll_voters.where(voter_id: users.select(:id)).pluck(:voter_id)
    users = users.where.not(id: existing_voter_ids)
    group_member_ids = poll.group ? poll.group.members.where(id: users.select(:id)).pluck(:id).to_set : Set.new
    rows = users.map do |user|
      {
        poll_id: poll.id,
        voter_id: user.id,
        inviter_id: actor.id,
        group_member: group_member_ids.include?(user.id),
        ballot_submitted: false
      }
    end
    AnonymousPollVoter.insert_all(rows, unique_by: [:poll_id, :voter_id]) if rows.any?
    poll.anonymous_poll_voters.where(voter_id: users.select(:id))
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

      NotificationService.create!(
        kind: "poll_reminder",
        subject: poll,
        actor: actor,
        recipient_user_ids: users.pluck(:id),
        recipient_chatbot_ids: params[:recipient_chatbot_ids],
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

  def self.discard(poll:, actor:, &on_topic_item)
    actor.ability.authorize!(:destroy, poll)

    Sentry.metrics.count("poll.discard", attributes: { poll_type: poll.poll_type })
    Poll.transaction do
      poll.update(discarded_at: Time.now, discarded_by: actor.id)
      TopicItem.where(
        kind: [ "stance_created", "stance_updated" ],
        itemable_type: "Stance",
        itemable_id: poll.stances.select(:id)
      ).find_each(&:destroy!)
      poll.created_topic_item.update!(user_id: nil, child_count: 0, pinned: false)
      poll.topic.update_sequence_info!
    end

    ReindexPollWorker.perform_later(poll.id)
    MessageChannelService.publish_models([poll.created_topic_item], scope: {current_user: actor, current_user_id: actor.id}, group_id: poll.group_id)
    on_topic_item&.call(poll.created_topic_item)
    poll
  end

  def self.close(poll:, actor:, &on_topic_item)
    actor.ability.authorize! :close, poll
    topic_item = Poll.transaction do
      do_closing_work(poll: poll)
      TopicItems::PollClosedByUser.create!(
        itemable: poll,
        user: actor,
        created_at: poll.closed_at
      )
    end
    publish_topic_if_active(poll)
    on_topic_item&.call(topic_item)
    poll
  end

  def self.reopen(poll:, params:, actor:, &on_topic_item)
    actor.ability.authorize! :reopen, poll

    poll.assign_attributes(closing_at: params[:closing_at], closed_at: nil, opening_at: nil, opened_at: Time.now)
    poll.stv_results = nil if poll.poll_type == 'stv'
    unless poll.valid?
      Sentry.metrics.count("poll.reopen_failed", attributes: { columns: poll.errors.attribute_names.join(',') })
      return false
    end

    topic_item = Poll.transaction do
      poll.save!

      topic_item = TopicItems::PollReopened.create!(
        itemable: poll,
        user: actor
      )
      announce_poll_opened(poll) if poll.notify_on_open
      topic_item
    end
    EventBus.broadcast('poll_reopen', poll, actor)
    publish_topic_if_active(poll)
    on_topic_item&.call(topic_item)
    poll
  end

  def self.publish_closing_soon(now: Time.current)
    hour_start = (now + 1.day).at_beginning_of_hour
    hour_finish = hour_start + 1.hour
    this_hour_tomorrow = hour_start..hour_finish
    Poll.closing_soon_not_published(this_hour_tomorrow).where.not(voting_system: Poll.voting_systems[:anonymous_ballot]).each do |poll|
      NotificationService.create!(
        kind: "poll_closing_soon",
        subject: poll,
        actor: poll.author
      )
    end

    Poll.closing_soon_not_published(now..(now + 24.hours))
        .where(voting_system: Poll.voting_systems[:anonymous_ballot])
        .find_each do |poll|
      opening_at = poll.opening_at || poll.opened_at
      next unless opening_at && poll.closing_at - opening_at >= 24.hours
      next unless poll.anonymous_poll_voters.where(ballot_submitted: false).exists?

      NotificationService.create!(
        kind: "poll_closing_soon",
        subject: poll,
        actor: poll.author
      )
    end
  end

  def self.open_scheduled_polls
    Poll.kept
        .where(opened_at: nil)
        .where("opening_at IS NOT NULL AND opening_at <= ?", Time.now)
        .each do |poll|
          publish_topic_if_active(poll) if open_poll_if_ready(poll)
        end
  end

  def self.group_members_added(group_id)
    return if group_id.nil?

    Poll.active.joins(:topic).where(topics: { group_id: group_id }, specified_voters_only: false).each do |poll|
      if poll.detached_anonymous?
        Poll.transaction do
          poll.lock!
          create_anonymous_poll_voters(poll: poll, actor: poll.author, params: {})
          poll.update_counts!
        end
      else
        create_anyone_can_vote_stances(poll)
      end
    end
  end

  def self.create_anyone_can_vote_stances(poll)
    raise "only use on specified_voters_only=false" if poll.specified_voters_only
    return if poll.detached_anonymous?

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
      CloseExpiredPollWorker.perform_later(poll.id)
    end
  end

  def self.do_closing_work(poll:)
    Poll.transaction do
      poll.lock!
      next if poll.closed_at

      if poll.detached_anonymous?
        poll.stv_results = StvCountService.count(poll) if poll.poll_type == "stv"
        poll.update!(closed_at: Time.current)
        poll.update_counts!
        poll.topic.update_active_polls_count
        ReindexPollWorker.perform_later(poll.id)
        next
      end

      StanceReceipt.where(poll_id: poll.id).delete_all
      StanceReceipt.insert_all build_receipts(poll)

      if poll.topic && poll.hide_results == 'until_closed'
        stance_ids = poll.stances.latest.reject(&:body_is_blank?).map(&:id)
        stance_ids_with_items = TopicItem.where(
          kind: %w[stance_created stance_updated],
          itemable_type: "Stance",
          itemable_id: stance_ids
        ).pluck(:itemable_id)
        Stance.where(id: stance_ids - stance_ids_with_items).find_each do |stance|
          TopicItems::StanceCreated.new(
            itemable: stance,
            created_at: stance.cast_at || stance.created_at
          ).save!
        end
        TopicService.repair(poll.topic_id)
      end

      if poll.poll_type == 'stv'
        poll.stv_results = StvCountService.count(poll)
      end

      poll.update(closed_at: Time.now)
      # why isn't active polls count being updated?
      poll.topic.update_active_polls_count

      if poll.poll_type == 'stv'
        poll.save!  # persist stv_results in custom_fields
      end

      ReindexPollWorker.perform_later(poll.id)
    end
  end

  def self.build_receipts(poll)
    if poll.detached_anonymous?
      return poll.anonymous_poll_voters.map do |voter|
        {
          poll_id: poll.id,
          voter_id: voter.voter_id,
          inviter_id: voter.inviter_id,
          vote_cast: voter.ballot_submitted
        }
      end
    end

    poll.stances.latest.map do |stance|
      {
        poll_id: poll.id,
        voter_id: stance.participant_id,
        inviter_id: stance.inviter_id,
        invited_at: stance.created_at,
        vote_cast: !!stance.cast_at
      }
    end
  end

  # def self.destroy(poll:, actor:)
  #   actor.ability.authorize! :destroy, poll
  #   poll.destroy
  #
  #   EventBus.broadcast('poll_destroy', poll, actor)
  # end

  def self.calculate_results(poll, poll_options)
    return calculate_stv_results(poll, poll_options) if poll.poll_type == 'stv'

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
        voter_ids: option.voter_ids.take(50),
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
          voter_ids: poll.none_of_the_above_voters.map(&:id).take(50),
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
          voter_ids: poll.undecided_voters.map(&:id).take(50),
          voter_count: poll.undecided_voters_count,
          color: '#BBBBBB',
          test_result: nil
        }.with_indifferent_access.freeze
      )
    end
    l
  end

  # STV results are computed at close time and stored in custom_fields.
  # This method returns a simplified per-candidate result list for the
  # standard results serialization (the round-by-round data is served
  # separately via stv_results).
  def self.calculate_stv_results(poll, poll_options)
    stv = poll.stv_results || {}
    elected_ids = (stv['elected'] || []).map { |e| e['poll_option_id'] }
    tied_ids = (stv['tied'] || []).map { |e| e['poll_option_id'] }
    elected_rounds = (stv['elected'] || []).each_with_object({}) { |e, h| h[e['poll_option_id']] = e['round_elected'] }

    poll_options.map do |option|
      status = if elected_ids.include?(option.id)
                 'elected'
               elsif tied_ids.include?(option.id)
                 'tied'
               elsif poll.closed_at
                 'not_elected'
               else
                 'pending'
               end

      {
        id: option.id,
        poll_id: option.poll_id,
        name: option.name,
        name_format: poll.poll_option_name_format,
        icon: option.icon,
        rank: elected_ids.index(option.id)&.+(1),
        stv_status: status,
        round_elected: elected_rounds[option.id],
        score: option.total_score,
        score_percent: 0,
        max_score_percent: 0,
        voter_percent: poll.voters_count > 0 ? ((option.voter_count.to_f / poll.voters_count.to_f) * 100) : 0,
        average: option.average_score,
        voter_scores: option.voter_scores,
        voter_ids: option.voter_ids.take(50),
        voter_count: option.voter_count,
        color: option.color,
        test_result: nil
      }.with_indifferent_access.freeze
    end
  end

  def self.open_poll_if_ready(poll)
    return false if poll.opened_at
    return false unless poll.closing_at
    return false if poll.opening_at.present? && poll.opening_at > Time.now

    Poll.transaction do
      poll.update!(opened_at: Time.now)
      announce_poll_opened(poll) if poll.notify_on_open
    end
    true
  end

  def self.publish_topic_if_active(poll)
    topic = poll.topic
    topic.update_active_polls_count
    scope = {exclude_types: ['group']}
    MessageChannelService.publish_models([topic], group_id: topic.group_id, scope: scope) if topic.group_id
    topic.guests.find_each do |user|
      MessageChannelService.publish_models([topic], user_id: user.id, scope: scope)
    end
  end

  def self.announce_poll_opened(poll)
    if poll.detached_anonymous?
      recipient_user_ids = poll.anonymous_poll_voters.where.not(voter_id: poll.author_id).pluck(:voter_id)
      return if recipient_user_ids.empty?

      create_poll_announced_notification!(
        poll: poll,
        actor: poll.author,
        stances: [],
        recipient_user_ids: recipient_user_ids,
      )
      return
    end

    stances = poll.stances.latest.where.not(participant_id: poll.author_id)
    return if stances.empty?

    create_poll_announced_notification!(
      poll: poll,
      actor: poll.author,
      stances: stances,
    )
  end

  def self.create_poll_announced_notification!(poll:, actor:, stances: [],
                                               recipient_user_ids: [], recipient_chatbot_ids: [],
                                               recipient_message: nil,
                                               **)
    stance_recipient_ids = Array(stances).filter_map(&:participant_id)
    NotificationService.create!(
      kind: "poll_announced",
      subject: poll.created_topic_item || poll,
      actor: actor,
      recipient_user_ids: (stance_recipient_ids + Array(recipient_user_ids)).uniq,
      recipient_chatbot_ids: recipient_chatbot_ids,
      recipient_message: recipient_message
    )
  end
end
