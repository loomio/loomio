class VoteSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :position, :statement, :relationships, :proposal_id



  has_one :author, serializer: AuthorSerializer

  def proposal_id
    object.motion_id
  end

  def relationships
    {
      author: { foreign_key: 'author_id', collection: 'authors' }
    }
  end
end
