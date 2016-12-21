class PollSerializer < ActiveModel::Serializer
  attributes :id, :key, :name, :description

  has_one :discussion, serializer: DiscussionSerializer
end
