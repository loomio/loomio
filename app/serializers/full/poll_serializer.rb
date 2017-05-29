class Full::PollSerializer < ::PollSerializer
  attributes :poll_option_names, :anyone_can_participate, :email_community_id,
             :mentioned_usernames, :complete

  has_one :discussion, serializer: DiscussionSerializer, root: :discussions
  has_many :poll_options, serializer: PollOptionSerializer, root: :poll_options
  has_many :attachments, serializer: AttachmentSerializer, root: :attachments

  def complete
    true
  end

  def removed_poll_option_ids
    object.poll_option_attributes.select { |attr| attr[:_destroy] }.map { |attr| attr[:id] }
  end

  def email_community_id
    object.community_of_type(:email, build: true).tap(&:save).id
  end

end
