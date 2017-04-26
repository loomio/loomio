class PollSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :discussion_id, :group_id, :key, :poll_type, :title, :details, :mentioned_usernames, :stance_data, :stance_counts, :matrix_counts, :closed_at, :closing_at, :stances_count, :did_not_votes_count, :created_at, :poll_option_names,
             :multiple_choice, :custom_fields, :email_community_id, :anyone_can_participate

  has_one :author, serializer: UserSerializer, root: :users
  has_one :current_outcome, serializer: OutcomeSerializer, root: :outcomes
  has_many :poll_options, serializer: PollOptionSerializer, root: :poll_options
  has_many :attachments, serializer: AttachmentSerializer, root: :attachments
  has_one :my_stance, serializer: StanceSerializer, root: :stances

  def removed_poll_option_ids
    object.poll_option_attributes.select { |attr| attr[:_destroy] }.map { |attr| attr[:id] }
  end

  def my_stance
    @my_stances_cache ||= scope[:my_stances_cache].get_for(object) if scope[:my_stances_cache]
  end

  def email_community_id
    object.community_of_type(:email, build: true).id
  end

  def include_matrix_counts?
    object.chart_type == 'matrix'
  end
end
