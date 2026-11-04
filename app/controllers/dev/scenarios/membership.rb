module Dev::Scenarios::Membership
  def setup_membership_notification_history
    group = create_group
    membership = group.memberships.find_by!(user: emilio)
    EmailSuppressionService.record!(email: emilio.email, reason: 'complaint', source_key: 'scenario:history-block')
    invitation = Notification.create!(kind: 'membership_created', subject: group, actor: patrick,
      recipient_user_ids: [emilio.id], recipient_message: 'Please join the wider group discussion',
      created_at: 1.day.ago, deliveries_generated_at: 1.day.ago)
    delivery = NotificationDelivery.create!(notification: invitation, recipient: emilio, channel: 'email',
      delivered_at: 1.day.ago)
    delivery.events.create!(kind: 'sent', source_key: 'scenario:send', occurred_at: delivery.delivered_at)
    delivery.events.create!(kind: 'delivered', source_key: 'scenario:delivery', occurred_at: 1.day.ago + 1.minute)

    # Synthetic feedback lets the history preview show every outcome without
    # sending mail or depending on a provider. Only this member receives it.
    {
      delayed: '4.4.7 Delivery temporarily delayed',
      rejected: '554 Message rejected by the email service',
      bounced: '5.1.1 Recipient address does not exist',
      complained: 'Recipient reported this email as spam',
      skipped: 'Email address is blocked after a spam complaint'
    }.each_with_index do |(kind, detail), index|
      sent_at = (12 - index).hours.ago
      notification = Notification.create!(kind: 'membership_resent', subject: membership, actor: patrick,
        recipient_message: "Invitation history preview: #{kind}", created_at: sent_at, deliveries_generated_at: sent_at)
      email = NotificationDelivery.create!(notification: notification, recipient: emilio, channel: 'email',
        delivered_at: (%i[delayed bounced complained].include?(kind) ? sent_at : nil))
      if email.delivered_at
        email.events.create!(kind: 'sent', source_key: "scenario:#{kind}:send", occurred_at: sent_at)
      end
      email.events.create!(kind: kind, source_key: "scenario:#{kind}", occurred_at: sent_at + 1.minute, detail: detail)
    end

    Notification.create!(kind: 'membership_resent', subject: membership, actor: patrick, deliveries_generated_at: Time.current)
    sign_in patrick
    redirect_to group_path(group, slug: 'members')
  end

  def setup_group_as_member
    create_group.update_membership_counts
    sign_in jennifer
    redirect_to group_path(create_group)
  end

  def setup_membership_with_title
    sign_in patrick
    create_group.memberships.find_by(user: patrick).update(title: "Suzerain!")
    redirect_to group_path(create_group)
  end
end
