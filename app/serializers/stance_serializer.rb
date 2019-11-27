class StanceSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :reason, :reason_format, :latest, :mentioned_usernames, :created_at, :locale, :versions_count, :attachments

  has_one :poll, serializer: PollSerializer
  has_one :participant, serializer: UserSerializer, root: :users
  has_many :stance_choices, serializer: StanceChoiceSerializer, root: :stance_choices

  def participant
    scope && object.participant_for_client(user: scope[:current_user]).presence
  end

  def include_participant?
    participant.present?
  end
end
