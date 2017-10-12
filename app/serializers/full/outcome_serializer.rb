class Full::OutcomeSerializer < OutcomeSerializer
  has_many :attachments, serializer: AttachmentSerializer, root: :attachments
end
