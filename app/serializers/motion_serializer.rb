class MotionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id,
             :discussion_id,
             :name,
             :description,
             :outcome,
             :votes_count,
             :yes_votes_count,
             :no_votes_count,
             :abstain_votes_count,
             :block_votes_count,
             :did_not_votes_count,
             :created_at,
             :updated_at,
             :closing_at,
             :closed_at,
             :last_vote_at,
             :relationships

  has_one :author, serializer: AuthorSerializer
  has_one :outcome_author, serializer: AuthorSerializer, root: :authors

  def filter(keys)
    keys.delete(:outcome_author) unless object.outcome_author.present?
    keys
  end

  def relationships
    {
      author: { foreign_key: 'author_id', collection: 'authors' }
    }
  end
end
