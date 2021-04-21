class StanceSerializer < ApplicationSerializer
  attributes :id,
             :reason,
             :reason_format,
             :content_locale,
             :latest,
             :admin,
             :cast_at,
             :mentioned_usernames,
             :created_at,
             :locale,
             :versions_count,
             :attachments,
             :link_previews,
             :volume,
             :inviter_id,
             :poll_id,
             :participant_id,
             :revoked_at,
             :my_stance

  has_one :poll, serializer: PollSerializer, root: :polls
  has_one :participant, serializer: AuthorSerializer, root: :users
  has_many :stance_choices, serializer: StanceChoiceSerializer, root: :stance_choices

  def locale
    participant&.locale || group&.locale
  end

  def participant
    return nil if poll.anonymous?
    cache_fetch(:users_by_id, object.participant_id) { object.participant }
  end

  def participant_id
    return nil if poll.anonymous?
    object.participant_id
  end

  def stance_choices
    cache_fetch(:stance_choices_by_stance_id, object.id) { object.stance_choices }
  end

  def volume
    object[:volume]
  end

  def my_stance
    scope[:current_user_id] && object[:participant_id] == scope[:current_user_id]
  end

  def include_reason?
    my_stance || poll.show_results?
  end

  def include_stance_choices?
    include_reason?
  end

  def include_mentioned_usernames?
    include_reason? && reason_format == 'md'
  end

  def include_attachments?
    include_reason?
  end

  def include_link_previews?
    include_reason?
  end
end
