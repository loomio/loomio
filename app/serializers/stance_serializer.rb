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
             :poll_id,
             :participant_id,
             :revoked_at,
             :my_stance

  has_one :participant, serializer: AuthorSerializer, root: :users
  has_many :stance_choices, serializer: StanceChoiceSerializer, root: :stance_choices

  def volume
    object[:volume]
  end

  def my_stance
    scope && scope[:current_user] && object[:participant_id] == scope[:current_user]&.id
  end

  def include_reason?
    my_stance || object.poll.show_results?
  end

  def include_stance_choices?
    include_reason?
  end

  def include_mentioned_usernames?
    include_reason?
  end

  def include_attachments?
    include_reason?
  end
end
