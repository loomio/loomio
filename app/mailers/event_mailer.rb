class EventMailer < BaseMailer
  REPLY_DELIMITER = "﻿﻿"*4 # surprise! this is actually U+FEFF

  # TODO this should be NotificationMailer, and take a notification id
  def event(recipient_id, event_id)
    @current_user = @recipient = User.find_by!(id: recipient_id)
    @event = Event.find_by!(id: event_id)
    return if @event.eventable.nil?
    return if @event.eventable.respond_to?(:discarded?) && @event.eventable.discarded?

    if %w[Poll Stance Outcome].include? @event.eventable_type
      @poll = @event.eventable.poll 
    end

    if @event.eventable.respond_to? :discussion
      @discussion = @event.eventable.discussion
    end

    if @event.kind == "membership_created" && @event.eventable_type == "Group"
      # if the membership has been deleted, let it go
      return unless Membership.where(user_id: recipient_id, group_id: @event.eventable_id).exists?
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

    # this should be notification.i18n_key
    @event_key = if (@event.kind == 'user_mentioned' &&
       @event.eventable.respond_to?(:parent) &&
       @event.eventable.parent.present? &&
       @event.eventable.parent.author == @recipient)
      "comment_replied_to"
    else
      @event.kind
    end

    subject_params = {
      title: @event.eventable.title,
      group_name: @event.eventable.title, # cope for old translations
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
      subject_key: "notifications.with_title.#{@event_key}",
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
    return nil unless model.respond_to?(:discussion) && model.discussion.present?
    if model.discussion.group.present?
      "\"#{I18n.transliterate(model.discussion.group.full_name).truncate(50).delete('"')}\" <#{reply_to_address(model: model, user: user)}>"
    else
      "\"#{user.name}\" <#{reply_to_address(model: model, user: user)}>"
    end
  end
end