class ThreadMailer < BaseMailer
  layout 'thread_mailer'
  REPLY_DELIMITER = "﻿﻿"*4 # surprise! this is actually U+FEFF
  %w(new_discussion new_comment user_mentioned comment_replied_to).each do |action|
    define_method action, ->(recipient, event) { send_thread_email(recipient, event, action) }
  end

  private
  def send_thread_email(recipient, event, action)
    return if recipient == User.helper_bot

    @recipient  = recipient
    @event      = event
    @eventable  = event.eventable
    @discussion = @eventable.discussion
    @author     = @eventable.author
    @text       = @eventable.body
    @following  = DiscussionReader.for(discussion: @discussion, user: @recipient).volume_is_loud?
    @link       = polymorphic_url(@eventable)
    @text       = polymorphic_description(@eventable)
    @utm_hash   = utm_hash

    message_id_header                   = action_name == 'new_discussion' ? 'Message-ID' : 'In-Reply-To'
    headers[message_id_header]          = "<#{@discussion.id}@#{ENV['SMTP_DOMAIN']}>"
    headers['Precedence']               = 'bulk'
    headers['X-Auto-Response-Suppress'] = 'OOF'
    headers['Auto-Submitted']           = 'auto-generated'

    if @following
      subject_key = 'email.mentioned.subject'
      subject_params = { name: @author.name, title: @discussion.title }
    else
      subject_key = 'email.custom'
      subject_params = if @discussion.group
        { text: "[#{@discussion.group.full_name}] #{@discussion.title}" }
      else
        { text: "[#{@discussion.title}]" }
      end
    end

    send_single_mail to: @recipient.email,
                     from: from_user_via_loomio(@author),
                     reply_to: reply_to_address(discussion: @discussion, user: @recipient),
                     subject_key: subject_key,
                     subject_params: default_subject_params,
                     locale: @recipient.locale
  end
end
