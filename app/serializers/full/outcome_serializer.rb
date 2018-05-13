class Full::OutcomeSerializer < OutcomeSerializer
  has_many :documents, serializer: DocumentSerializer, root: :documents
end
