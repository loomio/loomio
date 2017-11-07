class StanceSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :reason, :latest, :mentioned_usernames, :created_at, :locale

  has_one :poll, serializer: PollSerializer
  has_one :participant, serializer: UserSerializer, root: :users
  has_many :stance_choices, serializer: StanceChoiceSerializer, root: :stance_choices

  def include_participant?
    !object.poll.anonymous || scope[:current_user] == object.participant
  end
end
