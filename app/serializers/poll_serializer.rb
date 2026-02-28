class PollSerializer < ApplicationSerializer
  attributes :id,
             :limit_reason_length,
             :attachments,
             :agree_target,
             :author_id,
             :anonymous,
             :can_respond_maybe,
             :chart_type,
             :chart_column,
             :closed_at,
             :closing_at,
             :opening_at,
             :opened_at,
             :created_at,
             :content_locale,
             :cast_stances_pct,
             :decided_voters_count,
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
             :reason_prompt,
             :shuffle_options,
             :show_none_of_the_above,
             :stance_counts,
             :specified_voters_only,
             :total_score,
             :title,
             :tags,
             :undecided_voters_count,
             :voter_can_add_options,
             :voters_count,
             :stance_reason_required,
             :versions_count,
             :dots_per_person,
             :max_score,
             :min_score,
             :minimum_stance_choices,
             :maximum_stance_choices,
             :meeting_duration,
             :poll_template_id,
             :poll_template_key,
             :quorum_pct,
             :quorum_count,
             :quorum_votes_required,
             :topic_id,
             :group_id

  has_one :author, serializer: AuthorSerializer, root: :users
  has_one :current_outcome, serializer: OutcomeSerializer, root: :outcomes
  has_one :my_stance, serializer: StanceSerializer, root: :stances
  has_one :topic, serializer: TopicSerializer, root: :topics
  has_many :poll_options, serializer: PollOptionSerializer, root: :poll_options

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
    :cast_stances_pct,
    :decided_voters_count,
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
    :stance_counts,
    :total_score,
    :specified_voters_only,
    :title,
    :undecided_voters_count,
    :voter_can_add_options,
    :voters_count,
    :stance_reason_required,
    :versions_count,
    :meeting_duration,
    :default_duration_in_days
  ]

  def include_stance_counts?
    poll.show_results?(voted: true)
  end

  def results
    PollService.calculate_results(object, poll_options)
  end

  def include_results?
    poll.show_results?(voted: true)
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

  def my_stance
    cache_fetch(:my_stances_by_poll_id, object.id) { Stance.latest.find_by(poll_id: object.id, participant_id: scope[:current_user_id]) }
  end

  def include_my_stance?
    my_stance.present?
  end

  def topic_id
    object.topic&.id
  end

  def group_id
    object.topic&.group_id
  end

  def topic
    object.topic
  end

  def include_topic?
    topic.present?
  end
end
