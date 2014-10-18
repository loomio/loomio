class CommentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :body, :discussion_id, :created_at, :updated_at

  has_one :author, serializer: UserSerializer, root: 'users'
  has_many :likers, serializer: UserSerializer, root: 'users'

  #has_one :parent, serializer: CommentSerializer, root: 'comments'

  def filter(keys)
    keys.delete(:parent) unless object.parent.present?
    keys
  end
end
