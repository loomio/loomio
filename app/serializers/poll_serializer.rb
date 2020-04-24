class PollSerializer < ApplicationSerializer
  attributes :id, :discussion_id, :group_id, :key, :poll_type, :title, :details, :details_format,
             :stance_data, :stance_counts, :matrix_counts, :anyone_can_participate, :voter_can_add_options, :deanonymize_after_close,
             :closed_at, :closing_at, :stances_count, :participants_count, :undecided_count, :cast_stances_pct, :versions_count,
             :created_at, :multiple_choice, :custom_fields, :poll_option_names,
             :notify_on_participate, :anonymous, :can_respond_maybe,
             :attachments, :mentioned_usernames, :author_id, :complete

  has_one :discussion, serializer: DiscussionSerializer, root: :discussions
  has_one :created_event, serializer: Events::BaseSerializer, root: :events
  has_one :group, serializer: GroupSerializer, root: :groups
  has_one :author, serializer: AuthorSerializer, root: :users
  has_one :current_outcome, serializer: OutcomeSerializer, root: :outcomes
  has_one :my_stance, serializer: StanceSerializer, root: :stances
  has_many :poll_options, serializer: PollOptionSerializer, root: :poll_options

  def complete
    true
  end

  def removed_poll_option_ids
    object.poll_option_attributes.select { |attr| attr[:_destroy] }.map { |attr| attr[:id] }
  end

  def include_group?
    super && object.group_id
  end

  # def my_stance
  #   object.stances.latest.find_by(participant: scope[:current_user]) if scope[:current_user]
  # end

  def my_stance
    @my_stances_cache ||= scope[:my_stances_cache].get_for(object) if scope && scope[:my_stances_cache]
  end

  def include_matrix_counts?
    object.chart_type == 'matrix'
  end
end
