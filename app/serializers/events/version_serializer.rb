class Events::VersionSerializer < Events::BaseSerializer
  has_one :eventable, polymorphic: true, serializer: ::VersionSerializer
  has_many :attachments, serializer: AttachmentSerializer, root: :attachments

  def attachments
    return Attachment.none unless object.eventable.item.present?
    object.eventable.item.attachments
  end
end
