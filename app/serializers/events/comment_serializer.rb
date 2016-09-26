class Events::CommentSerializer < Events::BaseSerializer
  has_many :attachments, serializer: AttachmentSerializer, root: :attachments
  has_many :likers, serializer: UserSerializer, root: :users

  def likers
    object.eventable.likers
  end

  def attachments
    object.eventable.attachments
  end

  def include_likers?
    Hash(scope)[:include_likers]
  end

  def include_attachments?
    Hash(scope)[:include_attachments]
  end
end
