class PollSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :discussion_id, :key, :poll_type, :title, :details, :mentioned_usernames, :stance_data, :closed_at, :closing_at

  has_one :author, serializer: UserSerializer, root: :users
  has_one :outcome, serializer: OutcomeSerializer, root: :outcomes
  has_many :poll_options, serializer: PollOptionSerializer, root: :poll_options
end
