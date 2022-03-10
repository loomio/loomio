class EventMailer < BaseMailer
  REPLY_DELIMITER = "﻿﻿"*4 # surprise! this is actually U+FEFF

  def event(recipient_id, event_id)
    @recipient = User.find_by!(id: recipient_id)
    @event = Event.find_by!(id: event_id)

    if %w[Poll Stance Outcome].include? @event.eventable_type
      @poll = @event.eventable.poll 
    end

    @discussion = @event.eventable.discussion
    @utm_hash = { utm_medium: 'email', utm_campaign: @event.kind }

    return if ENV['SPAM_REGEX'] && Regexp.new(ENV['SPAM_REGEX']).match(@recipient.email)
    return if User::BOT_EMAILS.values.include?(@recipient.email)
    return if @event.eventable.discarded?

    thread_kinds = %w[
      new_comment
      new_discussion
      discussion_edited
      discussion_announced
    ]

    headers = {
      "Precedence": :bulk,
      "X-Auto-Response-Suppress": :OOF,
      "Auto-Submitted": :"auto-generated"
    }

    # if @event.kind == 'new_discussion'
    #   headers['new_discussion' ? 'Message-ID' : 'In-Reply-To'] = 
    #     "<#{@event.eventable.discussion.id}@#{ENV['SMTP_DOMAIN']}>"
    #   end

    if @event.eventable.respond_to?(:calendar_invite) && @event.eventable.calendar_invite
      attachments['meeting.ics'] = {
        content_type:              'text/calendar',
        content_transfer_encoding: 'base64',
        content:                   Base64.encode64(@event.eventable.calendar_invite)
      }
    end

    send_single_mail(
      to: @recipient.email,
      from: from_user_via_loomio(@event.user),
      locale: @recipient.locale,
      reply_to: reply_to_address_with_group_name(model: @event.eventable, user: @recipient),
      subject_prefix: group_name_prefix(@event.eventable),
      subject_key: "notifications.with_title.#{@event.kind}",
      subject_params: {
        title: @event.eventable.title,
        poll_type: @poll && I18n.t("poll_types.#{@poll.poll_type}"),
        actor: @event.user.name 
      },
      subject_is_title: thread_kinds.include?(@event.kind)
    )
  end


end