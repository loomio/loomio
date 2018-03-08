class Full::DiscussionSerializer < ::DiscussionSerializer
  attributes :mentioned_usernames, :announcements_count, :complete
  has_many :documents, serializer: DocumentSerializer, root: :documents
  has_one :created_event, serializer: Events::SimpleSerializer, root: :events

  def complete
    true
  end
end
