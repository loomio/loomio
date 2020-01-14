class DiscussionMailer < BaseMailer
  layout 'discussion_mailer'
  REPLY_DELIMITER = "﻿﻿"*4 # surprise! this is actually U+FEFF
  %w(new_discussion invitation_created discussion_edited discussion_announced
     new_comment user_mentioned comment_replied_to new_comment).each do |action|
    define_method action, ->(recipient_id, event_id) { send_thread_email(recipient_id, event_id) }
  end

  private
  def send_thread_email(recipient_id, event_id)
    recipient = User.find_by!(id: recipient_id)
    event = Event.find_by!(id: event_id)
    return if recipient == User.helper_bot

    @info = DiscussionEmailInfo.new(recipient: recipient, event: event, action_name: action_name)

    headers[message_id_header] = message_id
    headers['Precedence'] = 'bulk'
    headers['X-Auto-Response-Suppress'] = 'OOF'
    headers['Auto-Submitted'] = 'auto-generated'

    send_single_mail  to: @info.recipient.email,
                      from: from_user_via_loomio(@info.actor),
                      reply_to: reply_to_address_with_group_name(model: @info.eventable, user: @info.recipient),
                      subject_key: event.email_subject_key || "discussion_mailer.#{action_name}.subject",
                      subject_params: { actor: @info.actor.name,
                                        group: @info.discussion.group.full_name,
                                        discussion: @info.discussion.title },
                      locale: @info.recipient.locale
  end

  def message_id_header
    action_name == 'new_discussion' ? 'Message-ID' : 'In-Reply-To'
  end

  def message_id
    "<#{@info.discussion.id}@#{ENV['SMTP_DOMAIN']}>"
  end
end
