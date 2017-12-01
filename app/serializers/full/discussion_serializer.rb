class Full::DiscussionSerializer < ::DiscussionSerializer
  attributes :mentioned_usernames
  has_many :documents, serializer: DocumentSerializer, root: :documents
  has_one :created_event, serializer: Events::SimpleSerializer, root: :events
end
