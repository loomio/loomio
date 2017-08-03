class Full::PollSerializer < ::PollSerializer
  attributes :poll_option_names, :mentioned_usernames, :complete

  has_one :guest_group, serializer: Simple::GroupSerializer, root: :groups
  has_one :discussion, serializer: DiscussionSerializer, root: :discussions
  has_many :attachments, serializer: AttachmentSerializer, root: :attachments
  has_one :invitation

  def complete
    true
  end

  def my_stance
    object.stances.latest.find_by(participant: scope[:current_user]) if scope[:current_user]
  end

  def removed_poll_option_ids
    object.poll_option_attributes.select { |attr| attr[:_destroy] }.map { |attr| attr[:id] }
  end

  def invitation
    scope[:invitation]
  end
end
