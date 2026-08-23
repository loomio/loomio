# Creates the notification occurrences implied by newly introduced user and
# group mentions. Domain services call this inside their write transaction so
# mention discovery is atomic with both the edited content and any timeline
# item, while channel delivery remains background work.
class MentionNotificationService
  def self.create!(subject:, actor:, already_notified_user_ids: [], notify: true)
    return [] unless notify

    mentioned_users = subject.newly_mentioned_users.to_a
    mentioned_groups = subject.newly_mentioned_groups.to_a
    notifications = []

    if mentioned_groups.any?
      notifications << NotificationService.create!(
        kind: "group_mentioned",
        subject: subject,
        actor: actor,
        audience_values: {
          group_ids: mentioned_groups.map(&:id),
          mentioned_user_ids: mentioned_users.map(&:id),
          already_notified_user_ids: Array(already_notified_user_ids).map(&:to_i).uniq
        }
      )
    end

    recipient_ids = mentioned_users.map(&:id)
    reply_recipient_id = if subject.is_a?(Comment) && subject.parent&.author_id.in?(recipient_ids)
      subject.parent.author_id
    end

    if reply_recipient_id && reply_recipient_id != actor.id
      notifications << create_user_notification!(
        kind: "comment_replied_to",
        subject: subject,
        actor: actor,
        recipient_user_ids: [ reply_recipient_id ]
      )
    end

    user_recipient_ids = recipient_ids.without(reply_recipient_id)
    if user_recipient_ids.any?
      notifications << create_user_notification!(
        kind: "user_mentioned",
        subject: subject,
        actor: actor,
        recipient_user_ids: user_recipient_ids
      )
    end

    notifications
  end

  def self.create_user_notification!(kind:, subject:, actor:, recipient_user_ids:)
    NotificationService.create!(
      kind: kind,
      subject: subject,
      actor: actor,
      recipient_user_ids: recipient_user_ids
    )
  end
  private_class_method :create_user_notification!
end
