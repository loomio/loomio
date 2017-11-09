class DocumentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :title, :icon, :color, :url, :model_id, :model_type, :created_at, :group_id
  has_one :author, serializer: UserSerializer, root: :users
  has_one :discussion, serializer: Simple::DiscussionSerializer, root: :discussions
  has_one :poll, serializer: Simple::PollSerializer, root: :polls

  def group_id
    object.group&.id
  end
end
