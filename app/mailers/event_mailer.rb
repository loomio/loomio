class EventMailer < BaseMailer
  REPLY_DELIMITER = "\uFEFF\uFEFF"*4 # surprise! this is actually U+FEFF

  def event(recipient_id, event_id)
    recipient = User.active.find_by!(id: recipient_id)
    event = Event.find_by!(id: event_id)
    notification = Notification.find_by(user_id: recipient_id, event_id: event_id)

    return if event.eventable.nil?
    return if event.eventable.respond_to?(:discarded?) && event.eventable.discarded?

    poll = if %w[Poll Stance Outcome].include? event.eventable_type
      event.eventable.poll
    end

    discussion = if event.eventable.respond_to? :discussion
      event.eventable.discussion
    end

    membership = if event.eventable.respond_to?(:group_id) && event.eventable.group_id
      m = Membership.active.find_by(
        group_id: event.eventable.group_id,
        user_id: recipient_id
      )

      # this might be necessary to comply with anti-spam rules
      # if someone does not respond to the invitation, don't send them more emails
      return if m &&
                !recipient.email_verified &&
                !["membership_created", "membership_resent"].include?(event.kind)
      m
    end

    utm_hash = { utm_medium: 'email', utm_campaign: event.kind }

    discussion_kinds = %w[
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

    if event.eventable.respond_to?(:calendar_invite) && event.eventable.calendar_invite
      attachments['meeting.ics'] = {
        content_type: 'text/calendar',
        content_transfer_encoding: 'base64',
        content: Base64.encode64(event.eventable.calendar_invite)
      }
    end

    # this should be notification.i18n_key
    event_key = if event.kind == 'user_mentioned' &&
                    event.eventable.respond_to?(:parent) &&
                    event.eventable.parent.present? &&
                    event.eventable.parent.author == recipient
                   "comment_replied_to"
                 elsif event.kind == 'poll_created'
                   'poll_announced'
                 else
                   event.kind
                 end

    subject_params = {
      title: TranslationService.plain_text(event.eventable.title_model, :title, recipient),
      poll_type: poll && I18n.t("poll_types.#{poll.poll_type}", locale: recipient.locale),
      actor: event.user.name,
      site_name: AppConfig.theme[:site_name]
    }

    component = case event.eventable_type
    when 'Poll', 'Outcome'
      Views::Email::PollMailer.new(
        event: event,
        recipient: recipient,
        event_key: event_key,
        poll: poll,
        notification: notification,
        discussion: discussion,
        membership: membership
      )
    when 'Discussion'
      Views::Email::DiscussionMailer.new(
        event: event,
        recipient: recipient,
        event_key: event_key,
        notification: notification,
        discussion: discussion,
        poll: poll,
        membership: membership
      )
    when 'Comment'
      Views::Email::CommentMailer.new(
        event: event,
        recipient: recipient,
        event_key: event_key,
        notification: notification,
        discussion: discussion,
        poll: poll,
        membership: membership
      )
    when 'Stance'
      Views::Email::StanceMailer.new(
        event: event,
        recipient: recipient,
        event_key: event_key,
        notification: notification,
        discussion: discussion,
        poll: poll,
        membership: membership
      )
    when 'Membership'
      Views::Email::MembershipMailer.new(
        event: event,
        recipient: recipient,
        event_key: event_key
      )
    when 'Group'
      Views::Email::GroupMailer.new(
        event: event,
        recipient: recipient,
        event_key: event_key
      )
    when 'MembershipRequest'
      Views::Email::MembershipRequestMailer.new(
        event: event,
        recipient: recipient,
        event_key: event_key,
        utm_hash: utm_hash
      )
    when 'ReceivedEmail'
      Views::Email::ReceivedEmailMailer.new(
        event: event,
        recipient: recipient,
        event_key: event_key
      )
    end

    return if spam?(recipient.email)

    I18n.with_locale(first_supported_locale(recipient.locale)) do
      subject = if discussion_kinds.include?(event.kind)
        group_name_prefix(event) + subject_params[:title]
      else
        group_name_prefix(event) + I18n.t("notifications.email_subject.#{event_key}", **subject_params)
      end

      mail(
        to: recipient.email,
        from: from_user_via_loomio(event.user),
        reply_to: reply_to_address_with_group_name(model: event.eventable, user: recipient),
        subject: subject
      ) do |format|
        format.html { render component }
      end
    end
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
