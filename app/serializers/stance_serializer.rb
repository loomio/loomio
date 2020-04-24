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
             :poll_id

  has_one :poll, serializer: PollSerializer
  has_one :participant, serializer: AuthorSerializer, root: :users
  has_many :stance_choices, serializer: StanceChoiceSerializer, root: :stance_choices

  def volume
    object[:volume]
  end

  def include_participant?
    super &&
    if object.poll.anonymous
      scope && object.participant == scope[:current_user]
    else
      true
    end
  end
end
