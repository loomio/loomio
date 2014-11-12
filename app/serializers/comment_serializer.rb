class CommentSerializer < ActiveModel::Serializer
  include Twitter::Autolink

  embed :ids, include: true
  attributes :id, :body, :discussion_id, :created_at, :updated_at, :parent_id

  has_one :author, serializer: UserSerializer, root: 'users'
  #has_one :parent, serializer: CommentSerializer, root: 'comments'
  has_many :likers, serializer: UserSerializer, root: 'users'
  has_many :attachments, serializer: AttachmentSerializer, root: 'attachments'

  def body
    auto_link_usernames_or_lists object.body, username_url_base: '#', username_include_symbol: true
  end

  def filter(keys)
    keys.delete(:parent) unless object.parent.present?
    keys
  end
end
