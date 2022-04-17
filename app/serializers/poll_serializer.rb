class PollSerializer < ApplicationSerializer
  attributes :id,
             :allow_long_reason,
             :attachments,
             :author_id,
             :anyone_can_participate,
             :anonymous,
             :can_respond_maybe,
             :chart_type,
             :chart_column,
             :closed_at,
             :closing_at,
             :created_at,
             :content_locale,
             :cast_stances_pct,
             :custom_fields,
             :decided_voters_count,
             :details,
             :details_format,
             :discarded_at,
             :discarded_by,
             :discussion_id,
             :group_id,
             :hide_results,
             :key,
             :link_previews,
             :material_icon,
             :mentioned_usernames,
             :multiple_choice,
             :notify_on_closing_soon,
             :poll_type,
             :poll_option_names,
             :results,
             :result_columns,
             :poll_option_name_format,
             :icon_type,
             :shuffle_options,
             :stance_counts,
             :stances_in_discussion,
             :specified_voters_only,
             :secret_token,
             :total_score,
             :title,
             :undecided_voters_count,
             :voter_can_add_options,
             :voters_count,
             :versions_count

  has_one :discussion, serializer: DiscussionSerializer, root: :discussions
  has_one :created_event, serializer: EventSerializer, root: :events
  has_one :group, serializer: GroupSerializer, root: :groups
  has_one :author, serializer: AuthorSerializer, root: :users
  has_one :current_outcome, serializer: OutcomeSerializer, root: :outcomes
  has_one :my_stance, serializer: StanceSerializer, root: :stances
  has_many :poll_options, serializer: PollOptionSerializer, root: :poll_options
  has_many :tags, serializer: TagSerializer, root: :tags

  hide_when_discarded [
    :attachments,
    :link_previews,
    :author_id,
    :anyone_can_participate,
    :anonymous,
    :can_respond_maybe,
    :closed_at,
    :closing_at,
    :created_at,
    :content_locale,
    :cast_stances_pct,
    :custom_fields,
    :decided_voters_count,
    :details,
    :details_format,
    :hide_results,
    :allow_long_reason,
    :multiple_choice,
    :notify_on_closing_soon,
    :poll_type,
    :poll_option_names,
    :mentioned_usernames,
    :material_icon,
    :results,
    :shuffle_options,
    :stance_counts,
    :total_score,
    :stances_in_discussion,
    :specified_voters_only,
    :secret_token,
    :title,
    :undecided_voters_count,
    :voter_can_add_options,
    :voters_count,
    :versions_count
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

  def created_event
    cache_fetch([:events_by_kind_and_eventable_id, 'poll_created'], object.id) { object.created_event }
  end

  def include_mentioned_usernames?
    details_format == "md"
  end

  def removed_poll_option_ids
    object.poll_option_attributes.select { |attr| attr[:_destroy] }.map { |attr| attr[:id] }
  end

  def my_stance
    cache_fetch(:stances_by_poll_id, object.id) { Stance.latest.find_by(poll_id: object.id, participant_id: scope[:current_user_id]) }
  end

  def include_my_stance?
    my_stance.present?
  end
end
