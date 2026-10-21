module Dev::Scenarios::Membership
  def setup_membership_notification_history
    group = create_group
    membership = group.memberships.find_by!(user: emilio)
    invitation = Notification.create!(kind: 'membership_created', subject: group, actor: patrick,
      recipient_user_ids: [emilio.id], recipient_message: 'Please join the wider group discussion',
      created_at: 1.day.ago, deliveries_generated_at: 1.day.ago)
    delivery = NotificationDelivery.create!(notification: invitation, recipient: emilio, channel: 'email',
      delivered_at: 1.day.ago, email_subject: 'Join the group')
    delivery.events.create!(kind: 'sent', source_key: 'scenario:send', occurred_at: delivery.delivered_at)
    delivery.events.create!(kind: 'delivered', source_key: 'scenario:delivery', occurred_at: 1.day.ago + 1.minute)
    Notification.create!(kind: 'membership_resent', subject: membership, actor: patrick, deliveries_generated_at: Time.current)
    sign_in patrick
    redirect_to group_path(group)
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
