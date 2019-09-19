class Full::PollSerializer < ::PollSerializer
  attributes  :complete

  has_one :guest_group, serializer: Simple::GroupSerializer, root: :groups
  has_one :discussion, serializer: DiscussionSerializer, root: :discussions
  has_many :documents, serializer: DocumentSerializer, root: :documents
  has_one :created_event, serializer: Events::BaseSerializer, root: :events

  def complete
    true
  end

  def my_stance
    object.stances.latest.find_by(participant: scope[:current_user]) if scope[:current_user]
  end

  def removed_poll_option_ids
    object.poll_option_attributes.select { |attr| attr[:_destroy] }.map { |attr| attr[:id] }
  end
end
