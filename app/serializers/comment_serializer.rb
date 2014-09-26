class CommentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :body, :discussion_id, :created_at, :updated_at, :liker_ids_and_names, :relationships

  has_one :author, serializer: AuthorSerializer
  has_one :parent, serializer: CommentSerializer

  def filter(keys)
    keys.delete(:parent) unless object.parent.present?
    keys
  end
end
