class CommentSerializer < ActiveModel::Serializer
  attributes :id, :body, :discussion_id, :created_at, :updated_at, :liker_ids_and_names

  has_one :author
  has_one :parent
end
