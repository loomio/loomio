class Full::DiscussionSerializer < ::DiscussionSerializer
  attributes :mentioned_usernames
  has_one :active_proposal, serializer: Full::MotionSerializer, root: :proposals
  has_many :attachments, serializer: AttachmentSerializer, root: :attachments
end
