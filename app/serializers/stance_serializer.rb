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

  def participant
    if scope && scope[:current_user] && object[:participant_id] == scope[:current_user]&.id
      object.real_participant
    else
      object.participant
    end
  end

  def include_reason?
    !object.poll.hide_results_until_closed?
  end

  def include_stance_choices?
    !object.poll.hide_results_until_closed?
  end

  def include_mentioned_usernames?
    include_reason?
  end

  def include_attachments?
    include_reason?
  end
end
