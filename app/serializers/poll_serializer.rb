class PollSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :discussion_id, :group_id, :key, :poll_type, :title, :details,
             :stance_data, :stance_counts, :matrix_counts,
             :closed_at, :closing_at, :stances_count, :did_not_votes_count,
             :created_at, :multiple_choice, :custom_fields,
             :notify_on_participate

  has_one :author, serializer: UserSerializer, root: :users
  has_one :current_outcome, serializer: OutcomeSerializer, root: :outcomes
  has_one :my_stance, serializer: StanceSerializer, root: :stances


  def my_stance
    @my_stances_cache ||= scope[:my_stances_cache].get_for(object) if scope[:my_stances_cache]
  end


  def include_matrix_counts?
    object.chart_type == 'matrix'
  end
end
