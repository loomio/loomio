class ThreadMailer < BaseMailer
  layout 'thread_mailer'
  REPLY_DELIMITER = "﻿﻿"*4 # surprise! this is actually U+FEFF
  %w(new_discussion new_comment user_mentioned comment_replied_to).each do |action|
    define_method action, ->(recipient, event) { send_thread_email(recipient, event, action) }
  end

  def new_comment(recipient, event)
    return if Rails.env.development? # TODO: remove before deploy. This makes testing this soooo much faster.
    send_thread_email(recipient, event, :new_comment)
  end

  private
  def send_thread_email(recipient, event, action)
    return if recipient == User.helper_bot

    @recipient = recipient
    @event = event
    @eventable = event.eventable
    @discussion = @eventable.discussion
    @author = @eventable.author
    @text = @eventable.body
    @link = polymorphic_url(@eventable)


    @following = DiscussionReader.for(discussion: @discussion, user: @recipient).volume_is_loud?
    @utm_hash = utm_hash

    headers[message_id_header] = message_id
    headers['Precedence'] = 'bulk'
    headers['X-Auto-Response-Suppress'] = 'OOF'
    headers['Auto-Submitted'] = 'auto-generated'

    send_single_mail  to: @recipient.email,
                      from: from_user_via_loomio(@author),
                      reply_to: reply_to_address_with_group_name(discussion: @discussion, user: @recipient),
                      subject_key: "thread_mailer.#{action_name}.subject",
                      subject_params: { actor: @author.name,
                                        group: @discussion.group.full_name,
                                        discussion: @discussion.title },
                      locale: @recipient.locale
  end

  def message_id_header
    action_name == 'new_discussion' ? 'Message-ID' : 'In-Reply-To'
  end

  def message_id
    "<#{@discussion.id}@#{ENV['SMTP_DOMAIN']}>"
  end
end
