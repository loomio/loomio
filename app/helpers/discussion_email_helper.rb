module DiscussionEmailHelper
  include PrettyUrlHelper

  def target_url(eventable:, recipient:, action_name:, args: {})
    if discussion_reader = DiscussionReader.redeemable.find_by(user: recipient, discussion: eventable.discussion)
      args.merge!(discussion_reader_token: discussion_reader.token)
    end
    polymorphic_url(eventable, utm_hash(args, action_name))
  end

  def unfollow_url(discussion, action_name, recipient)
    utm_hash = utm_hash({discussion_id: discussion.id}, action_name)
    email_actions_unfollow_discussion_url(utm_hash.merge(unsubscribe_token: unsubscribe_token(recipient)))
  end

  def preferences_url(recipient, action_name)
    email_preferences_url(utm_hash({}, action_name).merge(unsubscribe_token: unsubscribe_token(recipient)))
  end

  def pixel_src(event, recipient)
    email_actions_mark_discussion_as_read_url(
      discussion_id:     event.eventable.discussion.id,
      event_id:          event.id,
      unsubscribe_token: recipient.unsubscribe_token,
      format: 'gif'
    )
  end

  def can_unfollow?(discussion, recipient, action_name)
    action_name == 'new_comment' &&
    DiscussionReader.for(discussion: discussion, user: recipient).volume_is_normal_or_loud?
  end

  private

  def utm_hash(args = {}, action_name)
    {
      utm_medium: 'email',
      utm_campaign: 'discussion_mailer',
      utm_source: action_name
    }.merge(args)
  end

  def unsubscribe_token(recipient)
    recipient.unsubscribe_token || 'none'
  end

end
