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
             :order_at,
             :option_scores

  has_one :poll, serializer: PollSerializer, root: :polls
  has_one :participant, serializer: AuthorSerializer, root: :users

  def order_at
    object.cast_at || object.created_at
  end

  def option_scores
    if ENV['JIT_POLL_COUNTS'] && object.option_scores == {} && object.cast_at
      object.update_option_scores!
    end
    object.option_scores
  end

  def include_option_scores?
    include_reason?
  end

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

  def volume
    object[:volume]
  end

  def include_reason?
    object.participant_id == scope[:current_user_id] || poll.show_results?(voted: true)
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
