class Simple::PollSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :key, :poll_type, :discussion_id, :group_id, :title, :details, :stance_counts, :matrix_counts
  has_one :my_stance, serializer: StanceSerializer, root: :stances
  has_one :author, serializer: UserSerializer, root: :users

  def my_stance
    scope[:my_stances_cache].get_for(object) if scope[:my_stances_cache]
  end

  def include_matrix_counts?
    object.dates_as_options
  end
end
