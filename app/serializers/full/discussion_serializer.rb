class Full::DiscussionSerializer < ::DiscussionSerializer
  attributes :complete
  has_many :documents, serializer: DocumentSerializer, root: :documents

  def complete
    true
  end
end
