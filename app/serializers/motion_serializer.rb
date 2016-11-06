class MotionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :key,
             :name,
             :kind,
             :description,
             :outcome,
             :activity_count,
             :voters_count,
             :members_count,
             :non_voters_count,
             :created_at,
             :updated_at,
             :closing_at,
             :closed_at,
             :closed_or_closing_at,
             :last_vote_at,
             :vote_counts,
             :activity_count,
             :group_id,
             :discussion_id

  has_one :author, serializer: UserSerializer, root: :users
  has_one :outcome_author, serializer: UserSerializer, root: :users

  def include_vote_counts?
    object.kind.to_sym == :loomio
  end
end
