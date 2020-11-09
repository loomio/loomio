class PollSerializer < ApplicationSerializer
  attributes :id, :discussion_id, :group_id, :key, :poll_type, :title, :details, :details_format,
             :stance_data, :stance_counts, :matrix_counts, :anyone_can_participate, :voter_can_add_options,
             :closed_at, :closing_at, :voters_count, :decided_voters_count, :undecided_voters_count, :cast_stances_pct, :versions_count,
             :created_at, :multiple_choice, :custom_fields, :poll_option_names,
             :notify_on_closing_soon, :anonymous, :can_respond_maybe, :hide_results_until_closed,
             :attachments, :mentioned_usernames, :author_id, :stances_in_discussion, :specified_voters_only,
             :discarded_at, :discarded_by, :secret_token

  has_one :discussion, serializer: DiscussionSerializer, root: :discussions
  has_one :created_event, serializer: Events::BaseSerializer, root: :events
  has_one :group, serializer: GroupSerializer, root: :groups
  has_one :author, serializer: AuthorSerializer, root: :users
  has_one :current_outcome, serializer: OutcomeSerializer, root: :outcomes
  has_one :my_stance, serializer: StanceSerializer, root: :stances
  has_many :poll_options, serializer: PollOptionSerializer, root: :poll_options

  hide_when_discarded [:details, :title]

  def include_mentioned_usernames?
    details_format == "md"
  end

  def removed_poll_option_ids
    object.poll_option_attributes.select { |attr| attr[:_destroy] }.map { |attr| attr[:id] }
  end

  def include_group?
    super && object.group_id
  end

  def my_stance
    object.stances.latest.where(participant_id: scope.current_user_id).first
  end
end
