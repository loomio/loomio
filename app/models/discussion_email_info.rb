class DiscussionEmailInfo
  include PrettyUrlHelper
  attr_reader :recipient, :event, :action_name

  def initialize(recipient:, event:, action_name:)
    @recipient = recipient
    @event = event
    @action_name = action_name
  end

  # So far eventable can be: Discussion, Comment, or Invitation
  def eventable
    @eventable ||= event.eventable
  end

  def actor
    @actor ||= event.user
  end

  def discussion
    @discussion ||= eventable.discussion
  end

  def links
    {
      eventable: polymorphic_url(eventable),
      unfollow:  email_actions_unfollow_discussion_url(utm_hash(discussion_id: discussion.id)),
      prefs:     email_preferences_url(utm_hash)
    }
  end

  def pixel_src
    email_actions_mark_discussion_as_read_url(
      discussion_id:     discussion.id,
      event_id:          event.id,
      unsubscribe_token: recipient.unsubscribe_token,
      format: 'gif'
    )
  end

  def utm_hash(args = {})
    {
      utm_medium: 'email',
      utm_campaign: 'discussion_mailer',
      utm_source: action_name,
      unsubscribe_token: recipient.unsubscribe_token
    }.merge(args)
  end

  def can_unfollow?
    recipient.is_logged_in? &&
    action_name == 'new_comment' &&
    DiscussionReader.for(discussion: discussion, user: recipient).volume_is_loud?
  end
end
