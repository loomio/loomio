class PollSerializer < ApplicationSerializer
  attributes :id,
             :limit_reason_length,
             :attachments,
             :agree_target,
             :author_id,
             :anonymous,
             :legacy_anonymous_vote_reasons_count,
             :anonymous_voter_eligible,
             :anonymous_ballot_submitted,
             :voter_has_access,
             :can_respond_maybe,
             :chart_type,
             :chart_column,
             :closed_at,
             :closing_at,
             :opening_at,
             :opened_at,
             :created_at,
             :content_locale,
             :participation_pct,
             :vote_count_cast,
             :details,
             :details_format,
             :discarded_at,
             :discarded_by,
             :hide_results,
             :key,
             :link_previews,
             :mentioned_usernames,
             :notify_on_closing_soon,
             :notify_on_open,
             :poll_type,
             :poll_option_names,
             :poll_option_name_format,
             :results,
             :result_columns,
             :result_heading_keys,
             :reason_prompt,
             :shuffle_options,
             :show_none_of_the_above,
             :scores_by_option,
             :specified_voters_only,
             :total_score,
             :title,
             :vote_count_uncast,
             :vote_count_total,
             :stance_reason_required,
             :versions_count,
             :points_per_voter,
             :score_max,
             :score_min,
             :choice_count_min,
             :choice_count_max,
             :meeting_duration,
             :stv_seats,
             :stv_method,
             :stv_quota,
             :stv_results,
             :poll_template_id,
             :poll_template_key,
             :quorum_pct,
             :quorum_reached,
             :quorum_threshold,
             :quorum_shortfall,
             :topic_id,
             :group_id,
             :weighted_voting

  has_one :author, serializer: AuthorSerializer, root: :users
  has_one :current_outcome, serializer: OutcomeSerializer, root: :outcomes
  has_one :topic, serializer: TopicSerializer, root: :topics
  has_one :my_stance, serializer: StanceSerializer, root: :stances
  has_many :poll_options, serializer: PollOptionSerializer, root: :poll_options
  has_many :reactions, serializer: ReactionSerializer, root: :reactions

  hide_when_discarded [
    :attachments,
    :link_previews,
    :author_id,
    :anonymous,
    :can_respond_maybe,
    :closed_at,
    :closing_at,
    :created_at,
    :content_locale,
    :participation_pct,
    :vote_count_cast,
    :details,
    :details_format,
    :hide_results,
    :limit_reason_length,
    :notify_on_closing_soon,
    :notify_on_open,
    :poll_type,
    :poll_option_names,
    :mentioned_usernames,
    :results,
    :shuffle_options,
    :scores_by_option,
    :total_score,
    :specified_voters_only,
    :title,
    :vote_count_uncast,
    :vote_count_total,
    :stance_reason_required,
    :versions_count,
    :meeting_duration,
    :default_duration_in_days
  ]

  def include_scores_by_option?
    results_visible?
  end

  def participation_visible?
    !object.anonymous? || object.closed?
  end

  def include_participation_pct?
    participation_visible?
  end

  def include_vote_count_cast?
    participation_visible?
  end

  def include_vote_count_uncast?
    participation_visible?
  end

  def include_quorum_shortfall?
    participation_visible?
  end

  # Optional response-scoped weights; calculations query live sums without a cache.
  def vote_weight_total
    return unless object.weighted_voting?

    cache_fetch(:vote_weight_total_by_poll_id, object.id) { nil }
  end

  def vote_weight_cast
    return unless object.weighted_voting?

    cache_fetch(:vote_weight_cast_by_poll_id, object.id) { nil }
  end

  def vote_weight_uncast
    return unless object.weighted_voting?

    cache_fetch(:vote_weight_uncast_by_poll_id, object.id) { nil }
  end

  def vote_weight_none_of_the_above
    return unless object.weighted_voting?

    cache_fetch(:vote_weight_none_of_the_above_by_poll_id, object.id) { nil }
  end

  def participation_pct
    return if object.discarded_at

    object.participation_pct(vote_weight_total: vote_weight_total, vote_weight_cast: vote_weight_cast)
  end

  def quorum_threshold
    object.quorum_threshold(vote_weight_total: vote_weight_total)
  end

  def quorum_shortfall
    object.quorum_shortfall(vote_weight_total: vote_weight_total, vote_weight_cast: vote_weight_cast)
  end

  def quorum_reached
    object.quorum_reached?(vote_weight_total: vote_weight_total, vote_weight_cast: vote_weight_cast)
  end

  def include_quorum_reached?
    participation_visible?
  end

  def results
    # A known-missing cache entry means the poll has no such voters.
    voter_ids_uncast = cache_fetch(:voter_ids_uncast_by_poll_id, object.id) { object.voters_uncast.ids } || []
    voter_ids_none_of_the_above = cache_fetch(:voter_ids_none_of_the_above_by_poll_id, object.id) { object.voters_none_of_the_above.ids } || []
    PollService.calculate_results(
      object, poll_options,
      voter_ids_uncast: voter_ids_uncast,
      voter_ids_none_of_the_above: voter_ids_none_of_the_above,
      vote_weight_total: vote_weight_total,
      vote_weight_uncast: vote_weight_uncast,
      vote_weight_none_of_the_above: vote_weight_none_of_the_above
    )
  end

  def include_results?
    results_visible?
  end

  def include_total_score?
    results_visible?
  end

  def stv_results
    object.stv_results
  end

  def include_stv_results?
    object.poll_type == 'stv' && results_visible?
  end

  def results_visible?
    poll.results_available?
  end

  def anonymous_voter
    return unless object.anonymous? && scope[:current_user_id]

    @anonymous_voter ||= object.anonymous_poll_voters.find_by(voter_id: scope[:current_user_id])
  end

  def anonymous_voter_eligible
    anonymous_voter.present?
  end

  def anonymous_ballot_submitted
    anonymous_voter&.ballot_submitted? || false
  end

  def voter_has_access
    user_id = scope[:current_user_id]
    if group_id
      is_member = if scope[:cache]
        scope[:cache].member_of_group?(group_id)
      else
        Membership.active.exists?(user_id: user_id, group_id: group_id)
      end
      return true if is_member
    else
      return true if object.author_id == user_id
    end

    reader = cache_fetch(:topic_readers_by_topic_id, object.topic_id) do
      TopicReader.find_by(topic_id: object.topic_id, user_id: user_id)
    end
    reader.present? && reader.guest? && reader.revoked_at.nil?
  end

  def group_id
    topic.group_id
  end

  def include_voter_has_access?
    scope[:current_user_id].present?
  end

  def legacy_anonymous_vote_reasons_count
    return 0 unless object.closed? && object.anonymous?

    object.legacy_anonymous_vote_reasons.count
  end

  # Voter state belongs to the current user. Shared payloads omit it rather
  # than send false, which would overwrite each recipient's own state.
  def include_anonymous_voter_eligible?
    object.anonymous? && scope[:current_user_id].present?
  end

  def include_anonymous_ballot_submitted?
    object.anonymous? && scope[:current_user_id].present?
  end

  def current_outcome
    cache_fetch(:outcomes_by_poll_id, object.id) { nil }
  end

  def poll_options
    cache_fetch(:poll_options_by_poll_id, object.id) { object.poll_options }
  end

  def poll_option_names
    cache_fetch(:poll_options_by_poll_id, object.id) { poll_options }.map(&:name)
  end

  def include_mentioned_usernames?
    details_format == "md"
  end

  def removed_poll_option_ids
    object.poll_option_attributes.select { |attr| attr[:_destroy] }.map { |attr| attr[:id] }
  end

  def group_id
    topic&.group_id
  end

  def my_stance
    cache_fetch(:my_stances_by_poll_id, object.id) { Stance.latest.find_by(poll_id: object.id, participant_id: scope[:current_user_id]) }
  end

  def include_my_stance?
    !object.anonymous? && my_stance.present?
  end
end
