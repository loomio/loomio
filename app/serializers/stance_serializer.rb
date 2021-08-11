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
             :option_scores,
             :my_stance

  has_one :poll, serializer: PollSerializer, root: :polls
  has_one :participant, serializer: AuthorSerializer, root: :users

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

  def my_stance
    scope[:current_user_id] && object[:participant_id] == scope[:current_user_id]
  end

  def include_reason?
    my_stance || poll.show_results?
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
