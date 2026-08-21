# This is the final 3.2 conversion implementation preserved as migration-only
# code so 3.3 can safely support direct upgrades after removing runtime support.
require "set"

class LegacyAnonymousVoteMigrationService
  class MigrationError < StandardError; end

  RESULT_FIELDS = %w[
    id score target_percent score_percent max_score_percent voter_percent
    average voter_count test_result stv_status round_elected
  ].freeze

  def self.eligible_poll_scope
    Poll.where(
      anonymous: true,
      voting_system: :stance
    ).where.not(closed_at: nil)
  end

  def self.migrate_all!(poll_id: nil, limit: nil, progress: nil)
    scope = eligible_poll_scope.order(:id)
    scope = scope.where(id: poll_id) if poll_id
    scope = scope.limit(limit) if limit

    stats = { polls: 0, ballots: 0, reasons: 0, attachments: 0, electorate_records: 0 }
    scope.pluck(:id).each do |id|
      result = migrate!(poll: Poll.find(id))
      result.each { |key, value| stats[key] += value if stats.key?(key) }
      progress&.call("Migrated anonymous poll #{id}: #{result[:ballots]} votes, #{result[:reasons]} reasons")
    end
    stats
  end

  def self.audit(poll:)
    poll.with_lock do
      validate_preconditions!(poll)
      current_stances = poll.stances.latest.decided.to_a
      {
        poll_id: poll.id,
        votes: current_stances.length,
        reasons: current_stances.count { |stance| reason_preserved?(stance) },
        attachments: ActiveStorage::Attachment.where(
          record_type: "Stance",
          record_id: poll.stances.select(:id)
        ).count,
        receipts: poll.stance_receipts.count
      }
    end
  end

  def self.migrate!(poll:)
    orphan_blob_ids = []
    result = Poll.transaction do
      poll.lock!
      validate_preconditions!(poll)
      LegacyAnonymousVoteMigrationCleanupService.remove_cross_poll_stance_choices!(poll: poll)
      poll.reload

      stances = poll.stances.latest.decided.order(:id).includes(:stance_choices).to_a
      stance_ids = poll.stances.pluck(:id)
      baseline = snapshot(poll, stances)
      ballot_ids_by_stance_id = stances.to_h do |stance|
        [ stance.id, Array.new(ballot_count_for_stance(stance)) { SecureRandom.uuid } ]
      end

      insert_ballots!(poll, stances, ballot_ids_by_stance_id)
      reason_count = insert_reasons!(stances, ballot_ids_by_stance_id)
      attachment_result = move_reason_attachments!(poll, stances)
      orphan_blob_ids.concat(attachment_result[:orphan_blob_ids])
      rebuild_poll_attachments!(poll) if attachment_result[:moved].positive?
      electorate_count = copy_complete_electorate!(poll, baseline)

      mark_poll_migrated!(poll, baseline)
      verify_detached_data!(poll.reload, baseline)
      remove_stance_content!(poll, stance_ids)

      raise MigrationError, "Stance deletion was incomplete" if Stance.where(poll_id: poll.id).exists?

      {
        polls: 1,
        ballots: ballot_ids_by_stance_id.values.sum(&:length),
        reasons: reason_count,
        attachments: attachment_result[:moved],
        electorate_records: electorate_count
      }
    end

    purge_unattached_blobs_later(orphan_blob_ids)
    result
  end

  def self.remove_stances!(poll:, stance_ids:)
    return 0 if stance_ids.empty?

    remove_stance_content!(poll, stance_ids)
    stance_ids.length
  end

  def self.normalize_reason(body, format)
    html = format == "html" ? body.to_s : MarkdownService.render_html(body.to_s)
    fragment = Nokogiri::HTML5::DocumentFragment.parse(html)

    fragment.css("script, style, img, video, audio, iframe").remove
    fragment.css("a").each do |node|
      node.remove if node["href"].to_s.include?("/rails/active_storage/")
    end
    fragment.css("br").each { |node| node.replace("\n") }
    fragment.css("li").each do |node|
      node.prepend_child("- ")
      node.add_child("\n")
    end
    fragment.css("p, div, h1, h2, h3, h4, h5, h6, blockquote, pre, tr").each do |node|
      node.add_child("\n\n")
    end

    fragment.text
            .tr("\u00A0", " ")
            .gsub(/\r\n?/, "\n")
            .lines
            .map(&:rstrip)
            .join("\n")
            .gsub(/\n{3,}/, "\n\n")
            .gsub(/(^- .*)\n\n(?=- )/, "\\1\n")
            .strip
  end

  def self.validate_preconditions!(poll)
    raise MigrationError, "Poll #{poll.id} is not anonymous" unless poll.anonymous?
    raise MigrationError, "Poll #{poll.id} is not stance based" unless poll.stance?
    raise MigrationError, "Poll #{poll.id} is not closed" unless poll.closed?
    raise MigrationError, "Poll #{poll.id} already has detached votes" if poll.anonymous_ballots.exists?
    raise MigrationError, "Poll #{poll.id} already has a detached electorate" if poll.anonymous_poll_voters.exists?
    mismatches = LegacyAnonymousVoteMigrationCleanupService.detached_ballot_choice_mismatches(poll.id)
    unless mismatches.empty?
      raise MigrationError, "Poll #{poll.id} has detached ballot choices for another poll"
    end
  end
  private_class_method :validate_preconditions!

  def self.snapshot(poll, stances)
    {
      vote_count: stances.length,
      ballot_count: stances.sum { |stance| ballot_count_for_stance(stance) },
      voter_count: poll.voters_count,
      undecided_voter_count: poll.undecided_voters_count,
      none_of_the_above_count: stances.count(&:none_of_the_above?),
      option_data: option_data_from_stances(stances),
      option_voter_counts: poll.poll_options.to_h { |option| [ option.id, option.voter_count ] },
      results: canonical_results(poll),
      stv_input: poll.poll_type == "stv" ? canonical_stv_input(StvCountService.extract_ballots(poll)) : nil,
      stv_result: poll.poll_type == "stv" ? StvCountService.count(poll).deep_stringify_keys : nil,
      reason_count: stances.count { |stance| reason_preserved?(stance) }
    }
  end
  private_class_method :snapshot

  def self.option_data_from_stances(stances)
    data = Hash.new { |hash, option_id| hash[option_id] = { score: 0, voters: 0 } }
    stances.each do |stance|
      stance.stance_choices.each do |choice|
        data[choice.poll_option_id][:score] += choice.score
        data[choice.poll_option_id][:voters] += 1
      end
    end
    data
  end
  private_class_method :option_data_from_stances

  def self.option_data_from_ballots(poll)
    poll.anonymous_ballot_choices
        .group(:poll_option_id)
        .pluck(:poll_option_id, Arel.sql("SUM(score)"), Arel.sql("COUNT(DISTINCT anonymous_ballot_id)"))
        .to_h { |option_id, score, voters| [ option_id, { score: score.to_i, voters: voters.to_i } ] }
  end
  private_class_method :option_data_from_ballots

  def self.canonical_results(poll)
    PollService.calculate_results(poll, poll.poll_options.reload).map do |result|
      result.to_h.stringify_keys.slice(*RESULT_FIELDS)
    end.sort_by { |result| result.fetch("id") }
  end
  private_class_method :canonical_results

  def self.canonical_stv_input(votes)
    votes.map { |vote| vote.map(&:to_i) }.sort
  end
  private_class_method :canonical_stv_input

  # Duplicate legacy choices affected the results users saw, so they cannot be
  # collapsed into one detached choice. Represent each repeated layer as another
  # anonymous ballot; this preserves option scores and voter counts without
  # retaining any link back to the legacy stance.
  def self.ballot_count_for_stance(stance)
    stance.stance_choices.group_by(&:poll_option_id).values.map(&:length).max || 1
  end
  private_class_method :ballot_count_for_stance

  def self.insert_ballots!(poll, stances, ballot_ids_by_stance_id)
    AnonymousBallot.insert_all!(
      stances.flat_map do |stance|
        ballot_ids_by_stance_id.fetch(stance.id).map.with_index do |ballot_id, index|
          {
            id: ballot_id,
            poll_id: poll.id,
            none_of_the_above: index.zero? && stance.none_of_the_above?
          }
        end
      end
    )

    choices = stances.flat_map do |stance|
      ballot_ids = ballot_ids_by_stance_id.fetch(stance.id)
      stance.stance_choices.group_by(&:poll_option_id).flat_map do |_option_id, option_choices|
        option_choices.map.with_index do |choice, index|
          {
            anonymous_ballot_id: ballot_ids.fetch(index),
            poll_option_id: choice.poll_option_id,
            score: choice.score
          }
        end
      end
    end
    AnonymousBallotChoice.insert_all!(choices) if choices.any?
  end
  private_class_method :insert_ballots!

  def self.insert_reasons!(stances, ballot_ids_by_stance_id)
    reasons = stances.filter_map do |stance|
      next unless reason_preserved?(stance)

      body = normalize_reason(stance.reason, stance.reason_format)
      next if body.blank?

      {
        anonymous_ballot_id: ballot_ids_by_stance_id.fetch(stance.id).first,
        body: body
      }
    end
    LegacyAnonymousVoteReason.insert_all!(reasons) if reasons.any?
    reasons.length
  end
  private_class_method :insert_reasons!

  def self.reason_preserved?(stance)
    stance.redacted_at.nil? &&
      stance.reason.present? &&
      stance.reason != "<p></p>" &&
      normalize_reason(stance.reason, stance.reason_format).present?
  end
  private_class_method :reason_preserved?

  def self.move_reason_attachments!(poll, stances)
    preserved_stance_ids = stances.reject { |stance| stance.redacted_at }.map(&:id).to_set
    all_stance_ids = Stance.where(poll_id: poll.id).pluck(:id)
    moved = 0
    orphan_blob_ids = []

    ActiveStorage::Attachment.where(record_type: "Stance", record_id: all_stance_ids).find_each do |attachment|
      if preserved_stance_ids.include?(attachment.record_id)
        duplicate = ActiveStorage::Attachment.exists?(
          record_type: "Poll",
          record_id: poll.id,
          name: "files",
          blob_id: attachment.blob_id
        )
        if duplicate
          orphan_blob_ids << attachment.blob_id
          attachment.delete
        else
          attachment.update_columns(
            record_type: "Poll",
            record_id: poll.id,
            name: "files",
            created_at: poll.created_at
          )
          moved += 1
        end
      else
        orphan_blob_ids << attachment.blob_id
        attachment.delete
      end
    end

    { moved: moved, orphan_blob_ids: orphan_blob_ids }
  end
  private_class_method :move_reason_attachments!

  def self.rebuild_poll_attachments!(poll)
    poll.files.reload
    poll.build_attachments
    poll.update_columns(attachments: poll.attachments)
  end
  private_class_method :rebuild_poll_attachments!

  def self.copy_complete_electorate!(poll, baseline)
    receipts = poll.stance_receipts.to_a
    voter_ids = receipts.map(&:voter_id)
    complete = receipts.length == baseline[:voter_count] &&
               voter_ids.none?(&:nil?) &&
               voter_ids.uniq.length == receipts.length &&
               receipts.none? { |receipt| receipt.vote_cast.nil? } &&
               receipts.count(&:vote_cast?) == baseline[:vote_count] &&
               User.where(id: voter_ids).count == voter_ids.length
    return 0 unless complete

    existing_user_ids = User.where(id: receipts.flat_map { |receipt| [ receipt.voter_id, receipt.inviter_id ] }.compact).pluck(:id).to_set
    AnonymousPollVoter.insert_all!(
      receipts.map do |receipt|
        {
          poll_id: poll.id,
          voter_id: receipt.voter_id,
          inviter_id: existing_user_ids.include?(receipt.inviter_id) ? receipt.inviter_id : nil,
          group_member: nil,
          ballot_submitted: receipt.vote_cast
        }
      end
    )
    receipts.length
  end
  private_class_method :copy_complete_electorate!

  def self.mark_poll_migrated!(poll, baseline)
    poll.update_columns(
      voting_system: Poll.voting_systems.fetch("anonymous_ballot"),
      hide_results: Poll.hide_results.fetch("until_closed"),
      stance_reason_required: Poll.stance_reason_requireds.fetch("disabled"),
      notify_on_closing_soon: Poll.notify_on_closing_soons.fetch("undecided_voters")
    )
    poll.reload
    poll.poll_options.each do |option|
      option.update_counts!
      option.update_columns(voter_count: baseline[:option_voter_counts].fetch(option.id))
    end
    poll.update_columns(
      stance_counts: poll.poll_options.reload.map(&:total_score),
      voters_count: baseline[:voter_count],
      undecided_voters_count: baseline[:undecided_voter_count],
      none_of_the_above_count: baseline[:none_of_the_above_count]
    )
  end
  private_class_method :mark_poll_migrated!

  def self.verify_detached_data!(poll, baseline)
    checks = {
      ballot_count: poll.anonymous_ballots.count == baseline[:ballot_count],
      option_data: option_data_from_ballots(poll) == baseline[:option_data],
      none_of_the_above: poll.anonymous_ballots.where(none_of_the_above: true).count == baseline[:none_of_the_above_count],
      results: canonical_results(poll) == baseline[:results],
      stv_input: poll.poll_type != "stv" || canonical_stv_input(StvCountService.extract_ballots(poll)) == baseline[:stv_input],
      stv_result: poll.poll_type != "stv" || StvCountService.count(poll).deep_stringify_keys == baseline[:stv_result],
      reasons: poll.legacy_anonymous_vote_reasons.count == baseline[:reason_count]
    }
    failed = checks.reject { |_name, passed| passed }.keys
    raise MigrationError, "Poll #{poll.id} verification failed: #{failed.join(', ')}" if failed.any?
  end
  private_class_method :verify_detached_data!

  def self.remove_stance_content!(poll, stance_ids)
    poll.create_missing_created_event! unless poll.created_event
    comment_ids = Comment.where(parent_type: "Stance", parent_id: stance_ids).pluck(:id)
    Comment.where(id: comment_ids).update_all(parent_type: "Poll", parent_id: poll.id)

    stance_events = Event.where(eventable_type: "Stance", eventable_id: stance_ids)
    stance_event_rows = stance_events.pluck(:id, :topic_id, :parent_id)
    stance_event_ids = stance_event_rows.map(&:first)

    comment_events = Event.where(eventable_type: "Comment", eventable_id: comment_ids)
    comment_event_rows = comment_events.pluck(:id, :topic_id, :parent_id)
    comment_events.update_all(
      parent_id: poll.created_event&.id,
      topic_id: poll.topic_id,
      sequence_id: nil,
      position: 0,
      position_key: nil
    )

    child_event_rows = Event.where(parent_id: stance_event_ids).pluck(:id, :topic_id, :parent_id)
    event_ids_to_delete = child_event_rows.map(&:first)
    event_ids_to_delete.concat(stance_event_ids)

    affected_parent_ids = (stance_event_rows + comment_event_rows + child_event_rows).filter_map(&:third).uniq
    affected_topic_ids = [ poll.topic_id ]
    affected_topic_ids.concat((stance_event_rows + comment_event_rows + child_event_rows).filter_map(&:second))
    affected_topic_ids.concat(Event.where(id: affected_parent_ids).where.not(topic_id: nil).distinct.pluck(:topic_id))

    Notification.where(event_id: event_ids_to_delete).delete_all
    Event.where(id: event_ids_to_delete).delete_all

    task_ids = Task.where(record_type: "Stance", record_id: stance_ids).pluck(:id)
    TasksUser.where(task_id: task_ids).delete_all
    Task.where(id: task_ids).delete_all
    Reaction.where(reactable_type: "Stance", reactable_id: stance_ids).delete_all
    Bookmark.where(bookmarkable_type: "Stance", bookmarkable_id: stance_ids).delete_all
    Translation.where(translatable_type: "Stance", translatable_id: stance_ids).delete_all
    PaperTrail::Version.where(item_type: "Stance", item_id: stance_ids).delete_all
    PgSearch::Document.where(searchable_type: "Stance", searchable_id: stance_ids).delete_all
    StanceChoice.where(stance_id: stance_ids).delete_all
    Stance.where(id: stance_ids).delete_all
    poll.events.where(kind: "poll_announced").find_each do |event|
      event.update_columns(custom_fields: event.custom_fields.except("stance_ids"))
    end

    affected_topic_ids.compact.uniq.each { |topic_id| TopicService.repair(topic_id) }
    verify_stance_content_removed!(stance_ids, stance_event_ids, event_ids_to_delete)
  end
  private_class_method :remove_stance_content!
  def self.verify_stance_content_removed!(stance_ids, stance_event_ids, deleted_event_ids)
    checks = {
      stances: Stance.where(id: stance_ids).count,
      choices: StanceChoice.where(stance_id: stance_ids).count,
      comments: Comment.where(parent_type: "Stance", parent_id: stance_ids).count,
      events: Event.where(eventable_type: "Stance", eventable_id: stance_ids).count,
      event_children: Event.where(parent_id: stance_event_ids).count,
      notifications: Notification.where(event_id: deleted_event_ids).count,
      reactions: Reaction.where(reactable_type: "Stance", reactable_id: stance_ids).count,
      bookmarks: Bookmark.where(bookmarkable_type: "Stance", bookmarkable_id: stance_ids).count,
      tasks: Task.where(record_type: "Stance", record_id: stance_ids).count,
      translations: Translation.where(translatable_type: "Stance", translatable_id: stance_ids).count,
      versions: PaperTrail::Version.where(item_type: "Stance", item_id: stance_ids).count,
      search_documents: PgSearch::Document.where(searchable_type: "Stance", searchable_id: stance_ids).count,
      attachments: ActiveStorage::Attachment.where(record_type: "Stance", record_id: stance_ids).count
    }.reject { |_name, count| count.zero? }
    return if checks.empty?

    raise MigrationError, "Stance-owned records remain: #{checks.map { |name, count| "#{name}=#{count}" }.join(', ')}"
  end
  private_class_method :verify_stance_content_removed!

  def self.purge_unattached_blobs_later(blob_ids)
    ActiveStorage::Blob.where(id: blob_ids.uniq).find_each do |blob|
      blob.purge_later unless blob.attachments.exists?
    end
  end
  private_class_method :purge_unattached_blobs_later
end
