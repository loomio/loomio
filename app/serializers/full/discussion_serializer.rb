class Full::DiscussionSerializer < ::DiscussionSerializer
  attributes :mentioned_usernames
  has_many :attachments, serializer: AttachmentSerializer, root: :attachments
end
