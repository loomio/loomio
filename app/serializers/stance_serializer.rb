class StanceSerializer < ApplicationSerializer
  attributes :id,
             :reason,
             :reason_format,
             :latest,
             :admin,
             :cast_at,
             :mentioned_usernames,
             :created_at,
             :locale,
             :versions_count,
             :attachments,
             :volume,
             :inviter_id,
             :revoked_at,
             :participant_id

  has_one :poll, serializer: PollSerializer
  has_one :participant, serializer: UserSerializer, root: :users
  has_many :stance_choices, serializer: StanceChoiceSerializer, root: :stance_choices

  def volume
    object[:volume]
  end

  def participant
    scope && object.participant_for_client(user: scope[:current_user]).presence
  end

  def include_participant?
    super && participant.present?
  end
end
