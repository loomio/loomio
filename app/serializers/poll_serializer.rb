class PollSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :discussion_id, :group_id, :key, :poll_type, :title, :details,
             :stance_data, :stance_counts, :matrix_counts, :anyone_can_participate, :voter_can_add_options,
             :closed_at, :closing_at, :stances_count, :undecided_user_count, :undecided_count,
             :created_at, :multiple_choice, :custom_fields, :poll_option_names,
             :notify_on_participate, :subscribed, :example, :anonymous, :can_respond_maybe

  has_one :author, serializer: UserSerializer, root: :users
  has_one :current_outcome, serializer: Full::OutcomeSerializer, root: :outcomes
  has_one :my_stance, serializer: StanceSerializer, root: :stances
  has_one :guest_group, serializer: Simple::GroupSerializer, root: :groups
  has_many :poll_options, serializer: PollOptionSerializer, root: :poll_options

  def subscribed
    object.poll_unsubscriptions.find_by(user: scope[:current_user]).blank?
  end

  def my_stance
    @my_stances_cache ||= scope[:my_stances_cache].get_for(object) if scope[:my_stances_cache]
  end

  def include_subscribed?
    (scope || {})[:current_user].present?
  end

  def include_matrix_counts?
    object.chart_type == 'matrix'
  end
end
