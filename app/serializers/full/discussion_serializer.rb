class Full::DiscussionSerializer < ::DiscussionSerializer
  attributes :mentioned_usernames
  has_many :documents, serializer: DocumentSerializer, root: :documents
end
