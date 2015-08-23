class Public::MotionSerializer < ActiveModel::Serializer

  attributes :key,
             :discussion_key,
             :name,
             :description,
             :outcome,
             :activity_count,
             :did_not_votes_count,
             :created_at,
             :updated_at,
             :closing_at,
             :closed_at,
             :last_vote_at,
             :vote_counts,
             :activity_count

  def discussion_key
    object.discussion.key
  end
end
