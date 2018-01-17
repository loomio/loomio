class Events::VersionSerializer < Events::BaseSerializer
  has_one :eventable, polymorphic: true, serializer: ::VersionSerializer
  has_many :documents, serializer: DocumentSerializer, root: :documents

  def documents
    return Document.none unless object.eventable.item.present?
    object.eventable.item.documents
  end
end
