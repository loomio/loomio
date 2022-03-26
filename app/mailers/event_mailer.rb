class EventMailer < BaseMailer
  REPLY_DELIMITER = "﻿﻿"*4 # surprise! this is actually U+FEFF

  def event(recipient_id, event_id)
    @current_user = @recipient = User.find_by!(id: recipient_id)
    @event = Event.find_by!(id: event_id)
    return if @event.eventable.respond_to?(:discarded?) && @event.eventable.discarded?

    if %w[Poll Stance Outcome].include? @event.eventable_type
      @poll = @event.eventable.poll 
    end

    if @event.eventable.respond_to? :discussion
      @discussion = @event.eventable.discussion
    end

    @utm_hash = { utm_medium: 'email', utm_campaign: @event.kind }

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

    template_name = @event.eventable_type.tableize.singularize
    template_name = 'poll' if @event.eventable_type == 'Outcome'
    template_name = 'group' if @event.eventable_type == 'Membership'

    subject_key = "notifications.with_title.#{@event.kind}" 
    subject_params = {
      title: @event.eventable.title,
      poll_type: @poll && I18n.t("poll_types.#{@poll.poll_type}"),
      actor: @event.user.name,
      site_name: AppConfig.theme[:site_name]
    }

    send_single_mail(
      to: @recipient.email,
      from: from_user_via_loomio(@event.user),
      locale: @recipient.locale,
      reply_to: reply_to_address_with_group_name(model: @event.eventable, user: @recipient),
      subject_prefix: group_name_prefix(@event),
      subject_key: subject_key,
      subject_params: subject_params,
      subject_is_title: thread_kinds.include?(@event.kind),
      template_name: template_name
    )
  end

  private
  def group_name_prefix(event)
    model = event.eventable
    if %w[membership_requested membership_created].include? event.kind
      ''
    else
      model.group.present? ? "[#{model.group.handle || model.group.full_name}] " : ''
    end
  end

  def reply_to_address_with_group_name(model:, user:)
    return nil unless user.is_logged_in?
    return nil unless model.respond_to?(:discussion_id) && model.discussion_id
    "\"#{I18n.transliterate(model.discussion.group.full_name).truncate(50).delete('"')}\" <#{reply_to_address(model: model, user: user)}>"
  end
end