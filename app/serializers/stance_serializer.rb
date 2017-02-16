class StanceSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :reason, :latest, :mentioned_usernames, :created_at

  has_one :poll, serializer: PollSerializer
  has_one :user, serializer: UserSerializer, root: :users
  has_one :visitor, serializer: VisitorSerializer, root: :visitors
  has_many :stance_choices, serializer: StanceChoiceSerializer, root: :stance_choices

  def user
    object.participant if object.participant.is_a?(User)
  end

  def visitor
    object.participant if object.participant.is_a?(Visitor)
  end
end
