class PollSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :key, :poll_type, :title, :details, :mentioned_usernames

  def mentioned_usernames
    []
  end

  has_one :discussion, serializer: DiscussionSerializer
  has_one :author, serializer: UserSerializer, root: :users
  has_many :poll_options, serializer: PollOptionSerializer, root: :poll_options
end
