# Defines the common lifecycle for turning one logical notification occurrence
# into channel-specific deliveries. Each notification kind owns only its
# audience rules in a subclass; insertion, retry safety, and
# dispatch remain consistent across all kinds.
class NotificationDeliveryResolver
  RESOLVERS = {
    "comment_replied_to" => "NotificationDeliveryResolvers::UserMentioned",
    "discussion_announced" => "NotificationDeliveryResolvers::DiscussionEvent",
    "discussion_edited" => "NotificationDeliveryResolvers::DiscussionEvent",
    "group_mentioned" => "NotificationDeliveryResolvers::GroupMentioned",
    "invitation_accepted" => "NotificationDeliveryResolvers::InvitationAccepted",
    "membership_created" => "NotificationDeliveryResolvers::MembershipCreated",
    "membership_resent" => "NotificationDeliveryResolvers::MembershipResent",
    "membership_request_approved" => "NotificationDeliveryResolvers::MembershipRequestApproved",
    "membership_requested" => "NotificationDeliveryResolvers::MembershipRequested",
    "new_coordinator" => "NotificationDeliveryResolvers::NewCoordinator",
    "new_delegate" => "NotificationDeliveryResolvers::NewDelegate",
    "new_discussion" => "NotificationDeliveryResolvers::DiscussionEvent",
    "outcome_announced" => "NotificationDeliveryResolvers::OutcomeAnnounced",
    "outcome_created" => "NotificationDeliveryResolvers::OutcomeChange",
    "outcome_review_due" => "NotificationDeliveryResolvers::OutcomeReviewDue",
    "outcome_updated" => "NotificationDeliveryResolvers::OutcomeChange",
    "poll_closing_soon" => "NotificationDeliveryResolvers::PollClosingSoon",
    "poll_edited" => "NotificationDeliveryResolvers::PollEdited",
    "poll_expired" => "NotificationDeliveryResolvers::PollExpired",
    "poll_announced" => "NotificationDeliveryResolvers::PollAnnounced",
    "poll_reminder" => "NotificationDeliveryResolvers::PollReminder",
    "reaction_created" => "NotificationDeliveryResolvers::ReactionCreated",
    "unknown_sender" => "NotificationDeliveryResolvers::UnknownSender",
    "user_added_to_group" => "NotificationDeliveryResolvers::UserAddedToGroup",
    "user_mentioned" => "NotificationDeliveryResolvers::UserMentioned"
  }.freeze

  attr_reader :notification

  def self.class_for(kind)
    resolver_name = RESOLVERS[kind.to_s]
    raise ArgumentError, "no delivery resolver for #{kind.inspect}" unless resolver_name

    resolver_name.constantize
  end

  def self.for(notification)
    class_for(notification.kind).new(notification)
  end

  def self.validate_subject!(_subject)
  end

  def self.translation_values(subject, actor, locale: actor.locale)
    I18n.with_locale(locale) do
      {
        name: actor.name,
        title: TranslationService.plain_text(subject.title_model, :title, actor),
        poll_type: (I18n.t("poll_types.#{subject.poll_type}") if subject.respond_to?(:poll_type))
      }.compact
    end
  end

  def initialize(notification)
    @notification = notification
  end

  def resolve!
    return [] if notification.deliveries_generated_at?

    recipients = recipients_by_channel.transform_values(&:to_a)
    recipients["email"] = email_recipients_without_complaints(recipients.fetch("email", []))
    recipients["push"] = active_push_subscriptions(recipients.fetch("push"))
    now = Time.current
    deliveries = []

    Notification.transaction do
      notification.lock!
      return [] if notification.deliveries_generated_at?

      rows = recipients.flat_map do |channel, channel_recipients|
        channel_recipients.map do |recipient|
          NotificationDeliveryService.attributes_for(
            notification: notification,
            recipient: recipient,
            channel: channel,
            translation_values: translation_values_for(recipient)
          ).merge(delivery_state(channel, now))
        end
      end

      NotificationDelivery.insert_all(
        rows,
        unique_by: NotificationDeliveryService::INDEX_IDENTITY
      ) if rows.any?

      notification.update!(deliveries_generated_at: now)
      deliveries = notification.notification_deliveries.reload.to_a
    end

    dispatch!(deliveries)
    deliveries
  end

  private

  # Subclasses select the logical user audience for every channel. This base
  # class applies delivery mechanics such as complaint filtering and expanding
  # push users into their active browser subscriptions.
  def recipients_by_channel
    raise NotImplementedError
  end

  # Intersect one event-level audience with independently eligible email and
  # push scopes so both external channels preserve the same recipient policy.
  def user_recipients_by_channel(recipients, email:, push:)
    recipient_ids = recipients.select(:id)
    {
      "in_app" => recipients,
      "email" => email.where("users.id": recipient_ids),
      "push" => push.where("users.id": recipient_ids)
    }
  end

  def explicit_users
    User.where(id: notification.recipient_user_ids)
  end

  def audience_ids(key)
    Array(notification.audience_values[key]).map(&:to_i)
  end

  def explicit_chatbots
    Chatbot.where(id: notification.recipient_chatbot_ids)
  end

  def translation_values_for(recipient)
    recipient = recipient.user if recipient.is_a?(PushSubscription)
    return notification.translation_values unless recipient.is_a?(User)

    self.class.translation_values(
      notification.subject_model,
      notification.actor,
      locale: recipient.locale
    )
  end

  def delivery_state(channel, now)
    return { status: "pending", delivered_at: nil } unless channel == "in_app"

    { status: "delivered", delivered_at: now }
  end

  def dispatch!(deliveries)
    deliveries.each do |delivery|
      case delivery.channel
      when "in_app"
        MessageChannelService.publish_models(
          [ delivery.notification ],
          user_id: delivery.recipient_id
        )
      when "email"
        DeliverNotificationEmailWorker.perform_later(delivery.id)
      when "chatbot"
        DeliverNotificationChatbotWorker.perform_later(delivery.id)
      when "push"
        DeliverNotificationPushWorker.perform_later(delivery.id)
      end
    end
  end

  # Filter the completed email audience once before creating delivery rows.
  # ApplicationMailer repeats this check in case a complaint arrives later.
  def email_recipients_without_complaints(email_recipients)
    user_ids = Array(email_recipients).map(&:id)
    return [] if user_ids.empty?

    User.no_spam_complaints.where(id: user_ids).to_a
  end

  # Expand each eligible user into one delivery recipient per active browser
  # subscription.
  def active_push_subscriptions(push_recipients)
    user_ids = Array(push_recipients).map(&:id)
    return [] if user_ids.empty?

    PushSubscription.active.includes(:user).where(user_id: user_ids).to_a
  end

  def notification_topic
    subject = notification.subject
    return subject.topic if subject.is_a?(TopicItem)

    model = notification.subject_model
    return model.topic if model.respond_to?(:topic) && model.topic
    return model.reactable.topic if model.respond_to?(:reactable) && model.reactable.respond_to?(:topic)
    model.reactable.parent.topic if model.respond_to?(:reactable) && model.reactable.respond_to?(:parent)
  end

  def notification_group
    model = notification.subject_model
    model.group if model.respond_to?(:group)
  end
end
