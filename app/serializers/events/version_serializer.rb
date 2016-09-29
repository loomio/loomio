class Events::VersionSerializer < Events::BaseSerializer
  has_one :eventable, polymorphic: true, serializer: ::VersionSerializer
  has_many :attachments, serializer: AttachmentSerializer, root: :attachments

  def attachments
    object.eventable.item.attachments
  end
end
