class DocumentSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :title, :icon, :color, :url, :model_id, :model_type, :created_at, :group_id
  has_one :author, serializer: UserSerializer, root: :users
  has_one :discussion, serializer: Simple::DiscussionSerializer, root: :discussions

  def discussion
    object.model.discussion
  end

  def group_id
    Hash(scope)[:group_id]
  end

  def include_discussion?
    object.model.respond_to?(:discussion)
  end

  def include_group_id?
    Hash(scope).has_key?(:group_id)
  end
end
