class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :discussion_id, :created_at, :updated_at, :liker_ids_and_names, :relationships

  has_one :author, serializer: AuthorSerializer
  has_one :parent, serializer: CommentSerializer

  def filter(keys)
    keys.delete(:parent) unless object.parent.present?
    keys
  end

  def relationships
    {
      author: { foreign_key: 'author_id', collection: 'authors' },
      parent: { foreign_key: 'parent_id', collection: 'comments' }
    }
  end


end
