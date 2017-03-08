class Full::PollSerializer < ::PollSerializer
  attributes :anyone_can_participate, :email_community_id
  has_one :discussion, serializer: DiscussionSerializer, root: :discussions

  def email_community_id
    object.community_of_type(:email).id
  end
end
