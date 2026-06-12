class PollService
  def self.build(params:, actor:)
    params = params.to_h.with_indifferent_access
    topic_params = params.extract!(*DiscussionService::TOPIC_ATTRS)

    poll = Poll.new
    poll.assign_attributes_and_files(params)
    poll.author = actor
    poll.prioritise_poll_options!

    # When private isn't explicitly sent (polls don't surface a privacy toggle),
    # derive it from the group's discussion_privacy_options so we don't create
    # a private topic in a group that only allows public threads.
    unless topic_params.key?(:private)
      gid = topic_params[:group_id]
      gid ||= poll.topic.group_id if poll.topic
      group = Group.find_by(id: gid)
      topic_params[:private] = group ? !group.public_discussions_only? : true
    end

    poll.topic ||= Topic.new topic_params.merge(topicable: poll)

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
      publish_topic_if_active(poll) if poll.opened_at
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
    params = params.to_h.with_indifferent_access
    topic_params = params.extract!(*DiscussionService::TOPIC_ATTRS).except(:group_id, :topic_id)
    poll.topic.update!(topic_params) if topic_params.any? && poll.topic.persisted?
    poll.assign_attributes_and_files(params.except(:poll_type, :poll_template_id, :poll_template_key))

    # check again, because the group id could be updated to a untrusted group
    actor.ability.authorize! :update, poll

    poll.prioritise_poll_options!

    return false unless poll.valid?

    Poll.transaction do
      poll.save!
      poll.update_counts!

      open_poll_if_ready(poll)

      GenericWorker.perform_later('SearchService', 'reindex_by_poll_id', poll.id)

      GenericWorker.perform_later('PollService', 'group_members_added', poll.group_id) if poll.group_id

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

    GenericWorker.perform_later('SearchService', 'reindex_by_poll_id', poll.id)
    MessageChannelService.publish_models([poll.created_event], scope: {current_user: actor, current_user_id: actor.id}, group_id: poll.group_id)
    poll.created_event
  end

  def self.close(poll:, actor:)
    actor.ability.authorize! :close, poll
    Poll.transaction do
      do_closing_work(poll: poll)
      Events::PollClosedByUser.publish!(poll, actor)
    end
    publish_topic_if_active(poll)
  end

  def self.reopen(poll:, params:, actor:)
    actor.ability.authorize! :reopen, poll

    poll.assign_attributes(closing_at: params[:closing_at], closed_at: nil, opening_at: nil, opened_at: Time.now)
    poll.stv_results = nil if poll.poll_type == 'stv'
    return false unless poll.valid?

    Poll.transaction do
      poll.save!

      EventBus.broadcast('poll_reopen', poll, actor)
      Events::PollReopened.publish!(poll, actor)
      announce_poll_opened(poll) if poll.notify_on_open
    end
    publish_topic_if_active(poll)
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

  def self.mark_closed_poll_topics_read(dry_run: false, progress: nil)
    stats = { topics: 0, readers_created: 0, readers_updated: 0 }
    processed = 0

    Poll.closed.kept.joins(:topic).where(topics: { topicable_type: 'Poll' }).find_each do |poll|
      processed += 1
      progress&.call("Processing poll #{processed} (id=#{poll.id})...") if (processed % 100).zero?

      topic = poll.topic
      ranges = RangeSet.ranges_from_list(topic.items.where.not(sequence_id: nil).order(:sequence_id).pluck(:sequence_id))
      next if ranges.empty?

      stats[:topics] += 1
      read_ranges_string = RangeSet.serialize(ranges)
      now = Time.zone.now
      reader_attrs = closed_poll_topic_reader_attrs(poll, topic, now)
      audience_user_ids = reader_attrs.map { |attrs| attrs[:user_id] }
      existing_user_ids = TopicReader.where(topic_id: topic.id, user_id: audience_user_ids).pluck(:user_id).to_set
      missing_reader_attrs = reader_attrs.reject { |attrs| existing_user_ids.include?(attrs[:user_id]) }
      active_reader_scope = TopicReader.active.where(topic_id: topic.id)

      if dry_run
        stats[:readers_created] += missing_reader_attrs.length
        stats[:readers_updated] += active_reader_scope.count + missing_reader_attrs.length
        next
      end

      TopicReader.insert_all(missing_reader_attrs, unique_by: :index_topic_readers_on_topic_id_and_user_id) if missing_reader_attrs.any?
      stats[:readers_created] += missing_reader_attrs.length
      stats[:readers_updated] += TopicReader.active.where(topic_id: topic.id).update_all(
        read_ranges_string: read_ranges_string,
        last_read_at: now,
        updated_at: now
      )
    end

    # Update counter caches in bulk after all readers are written
    unless dry_run
      topic_ids = Poll.closed.kept.joins(:topic).where(topics: { topicable_type: 'Poll' }).pluck('topics.id')
      progress&.call("Updating counters for #{topic_ids.length} closed poll topics...")

      topic_ids.each_slice(1_000).with_index(1) do |ids, batch|
        progress&.call("Updating closed poll topic counter batch #{batch}/#{(topic_ids.length / 1_000.0).ceil}...")
        update_topic_reader_counters_for_topic_ids(ids)
      end
    end

    stats
  end

  def self.update_topic_reader_counters_for_topic_ids(topic_ids)
    ids = Array(topic_ids).map(&:to_i).uniq
    return if ids.empty?

    ActiveRecord::Base.connection.execute(<<~SQL.squish)
      UPDATE topics
      SET seen_by_count = counts.seen_by_count,
          members_count = counts.members_count
      FROM (
        SELECT topic_id,
               COUNT(*) FILTER (WHERE last_read_at IS NOT NULL) AS seen_by_count,
               COUNT(*) FILTER (WHERE revoked_at IS NULL) AS members_count
        FROM topic_readers
        WHERE topic_id IN (#{ids.join(',')})
        GROUP BY topic_id
      ) counts
      WHERE topics.id = counts.topic_id
    SQL
  end

  def self.backfill_standalone_poll_stance_thread_items(dry_run: false, repair: true, mark_closed_read: true, progress: nil, progress_every: 100)
    progress&.call("Finding standalone poll stance events to attach...")
    rows = if dry_run
      ActiveRecord::Base.connection.select_all(<<~SQL.squish)
        SELECT topic_id FROM (#{standalone_poll_stance_thread_item_candidates_sql}) candidate_events
      SQL
    else
      ActiveRecord::Base.connection.exec_query(<<~SQL.squish)
        WITH candidate_events AS (#{standalone_poll_stance_thread_item_candidates_sql})
        UPDATE events
        SET topic_id = candidate_events.topic_id,
            sequence_id = NULL,
            parent_id = NULL,
            position = 0,
            position_key = NULL,
            depth = 0,
            updated_at = CURRENT_TIMESTAMP
        FROM candidate_events
        WHERE events.id = candidate_events.event_id
        RETURNING events.topic_id
      SQL
    end

    attached_topic_ids = rows.map { |row| row["topic_id"] }.uniq
    progress&.call("Found #{rows.length} stance events to attach across #{attached_topic_ids.length} standalone poll topics.")
    progress&.call("Finding standalone poll topics with unsequenced stance events...")
    repair_topic_ids = standalone_poll_topic_ids_newest_first(
      attached_topic_ids + standalone_poll_stance_thread_item_repair_topic_ids
    )
    progress&.call("Found #{repair_topic_ids.length} standalone poll topics to repair.")

    if repair && !dry_run
      progress&.call("Repairing #{repair_topic_ids.length} standalone poll topics...") if repair_topic_ids.any?
      repair_topic_ids.each.with_index(1) do |topic_id, index|
        progress&.call("Repairing standalone poll topic #{index}/#{repair_topic_ids.length} (topic_id=#{topic_id})...") if (index % progress_every).zero?
        TopicService.repair(topic_id)
      end
    end

    stats = { events: rows.length, topics: attached_topic_ids.length, repair_topics: repair_topic_ids.length }
    stats[:closed_read] = mark_closed_poll_topics_read(dry_run: dry_run, progress: progress) if mark_closed_read
    stats
  end

  def self.standalone_poll_stance_thread_item_repair_topic_ids
    ActiveRecord::Base.connection.select_values(<<~SQL.squish)
      SELECT DISTINCT events.topic_id
      FROM events
      INNER JOIN stances
        ON stances.id = events.eventable_id
       AND events.eventable_type = 'Stance'
      INNER JOIN polls
        ON polls.id = stances.poll_id
      INNER JOIN topics
        ON topics.id = polls.topic_id
       AND topics.topicable_type = 'Poll'
       AND topics.topicable_id = polls.id
      WHERE events.kind IN ('stance_created', 'stance_updated')
        AND events.topic_id = polls.topic_id
        AND events.sequence_id IS NULL
    SQL
  end

  def self.standalone_poll_topic_ids_newest_first(topic_ids)
    topic_ids = Array(topic_ids).uniq
    return [] if topic_ids.empty?

    Topic
      .joins("INNER JOIN polls ON polls.id = topics.topicable_id AND topics.topicable_type = 'Poll'")
      .where(id: topic_ids)
      .order("polls.created_at DESC, topics.id DESC")
      .pluck(:id)
  end

  def self.standalone_poll_stance_thread_item_candidates_sql
    <<~SQL.squish
      SELECT DISTINCT ON (events.eventable_id)
             events.id AS event_id,
             polls.topic_id AS topic_id
      FROM events
      INNER JOIN stances
        ON stances.id = events.eventable_id
       AND events.eventable_type = 'Stance'
      INNER JOIN polls
        ON polls.id = stances.poll_id
      INNER JOIN topics
        ON topics.id = polls.topic_id
       AND topics.topicable_type = 'Poll'
       AND topics.topicable_id = polls.id
      WHERE events.kind IN ('stance_created', 'stance_updated')
        AND events.topic_id IS NULL
        AND stances.latest = TRUE
        AND stances.revoked_at IS NULL
        AND stances.cast_at IS NOT NULL
        AND stances.reason IS NOT NULL
        AND stances.reason NOT IN ('', '<p></p>')
        AND (polls.closed_at IS NOT NULL OR polls.hide_results != 2)
        AND NOT EXISTS (
          SELECT 1 FROM events existing_events
          WHERE existing_events.eventable_type = 'Stance'
            AND existing_events.eventable_id = events.eventable_id
            AND existing_events.kind IN ('stance_created', 'stance_updated')
            AND existing_events.topic_id = polls.topic_id
        )
      ORDER BY events.eventable_id, events.created_at, events.id
    SQL
  end

  def self.closed_poll_topic_reader_attrs(poll, topic, timestamp)
    if topic.group_id.present?
      Membership.active.accepted.where(group_id: topic.group_id).pluck(:user_id, :volume).map do |user_id, volume|
        closed_poll_topic_reader_attr(topic, user_id, volume || TopicReader.volumes[:normal], false, false, timestamp)
      end
    else
      user_ids = ([poll.author_id] + poll.stances.where.not(participant_id: nil).pluck(:participant_id)).compact.uniq
      user_ids.map do |user_id|
        closed_poll_topic_reader_attr(topic, user_id, TopicReader.volumes[:normal], true, user_id == poll.author_id, timestamp)
      end
    end
  end

  def self.closed_poll_topic_reader_attr(topic, user_id, volume, guest, admin, timestamp)
    {
      topic_id: topic.id,
      user_id: user_id,
      volume: volume,
      guest: guest,
      admin: admin,
      created_at: timestamp,
      updated_at: timestamp
    }
  end

  def self.expire_lapsed_polls
    Poll.lapsed_but_not_closed.each do |poll|
      CloseExpiredPollWorker.perform_later(poll.id)
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

    GenericWorker.perform_later('SearchService', 'reindex_by_poll_id', poll.id)
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
    return if poll.opened_at
    return unless poll.closing_at
    return if poll.opening_at.present? && poll.opening_at > Time.now

    poll.update(opened_at: Time.now)
    announce_poll_opened(poll) if poll.notify_on_open
    publish_topic_if_active(poll)
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
    stances = poll.stances.latest.where.not(participant_id: poll.author_id)
    return if stances.empty?

    Events::PollAnnounced.publish!(
      poll: poll,
      actor: poll.author,
      stances: stances
    )
  end
end
