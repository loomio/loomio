class ClosedMotionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :key,
             :name,
             :description,
             :outcome,
             :activity_count,
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
  has_one :discussion, serializer: DiscussionSerializer, root: :discussions
  has_one :current_user_vote, serializer: VoteSerializer, root: :votes

  def current_user_vote
    @current_user_vote ||= scope[:vote_cache].get_for(object) if scope[:vote_cache]
  end

  private

  def include_current_user_vote?
    current_user_vote&.persisted?
  end

  def include_outcome_author?
    object.outcome_author.present?
  end

end
