class StanceSerializer < ApplicationSerializer
  attributes :id,
             :none_of_the_above,
             :reason,
             :reason_format,
             :content_locale,
             :latest,
             :cast_at,
             :mentioned_usernames,
             :created_at,
             :updated_at,
             :locale,
             :versions_count,
             :attachments,
             :link_previews,
             :inviter_id,
             :poll_id,
             :participant_id,
             :revoked_at,
             :redacted_at,
             :redactor_id,
             :order_at,
             :option_scores

  has_one :poll, serializer: PollSerializer, root: :polls
  has_one :participant, serializer: AuthorSerializer, root: :users
  has_many :reactions, serializer: ReactionSerializer, root: :reactions

  def order_at
    object.cast_at || object.created_at
  end

  def include_cast_at?
    !poll.anonymous?
  end

  def include_created_at?
    !poll.anonymous?
  end

  def include_updated_at?
    !poll.anonymous?
  end

  def include_order_at?
    !poll.anonymous?
  end

  def option_scores
    if ENV['JIT_POLL_COUNTS'] && object.option_scores == {} && object.cast_at
      object.update_option_scores!
    end
    object.option_scores
  end

  def include_none_of_the_above?
    include_results?
  end

  def include_option_scores?
    include_results?
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

  # For anonymous polls the raw stance id (a creation-ordered primary key) is an
  # identity oracle: sorted, it recovers the member order, and combined with
  # option_scores it reconstructs the ballot. Expose an unguessable, app-secret-
  # keyed pseudonymous id instead — except for the viewer's OWN stance, which
  # keeps its real id so they can still update/redact it.
  def id
    return object.id unless poll.anonymous?
    return object.id if object.participant_id == scope[:current_user_id]
    anonymous_id
  end

  def inviter_id
    return nil if poll.anonymous?
    object.inviter_id
  end

  private

  def anonymous_id
    OpenSSL::HMAC.hexdigest('SHA256', Rails.application.secret_key_base, "#{object.poll_id}:#{object.id}")[0, 20]
  end

  def include_reason?
    include_results? && !object.redacted_at
  end

  def include_results?
    !object.revoked_at && (object.participant_id == scope[:current_user_id] || poll.show_results?(voted: true))
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

  # ReactionSerializer exposes reactable_id (the real stance id), which would
  # re-introduce the identity oracle the anonymous_id is meant to remove — so
  # don't serialize per-stance reactions for anonymous polls.
  def include_reactions?
    !poll.anonymous?
  end
end
