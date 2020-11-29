class PollSerializer < ApplicationSerializer
  attributes :id,
             :attachments,
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
             :discarded_at,
             :discarded_by,
             :discussion_id,
             :group_id,
             :hide_results_until_closed,
             :key,
             :multiple_choice,
             :matrix_counts,
             :notify_on_closing_soon,
             :poll_type,
             :poll_option_names,
             :mentioned_usernames,
             :stance_data,
             :stance_counts,
             :stances_in_discussion,
             :specified_voters_only,
             :secret_token,
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

  hide_when_discarded [:details, :title, :author_id]


  def current_outcome
    cache_fetch(:outcomes_by_poll_id, object.id) { nil }
  end

  def poll_options
    cache_fetch(:poll_options_by_poll_id, object.id) { [] }
  end

  def poll_option_names
    cache_fetch(:poll_options_by_poll_id, object.id) { [] }.map(&:name)
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
    cache_fetch(:stances_by_poll_id, object.id) { nil }
  end
end
