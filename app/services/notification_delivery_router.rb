# Defines the common lifecycle for turning one logical notification occurrence
# into channel-specific deliveries. Each notification kind owns only its
# recipient rules in a subclass; insertion, retry safety, and dispatch remain
# consistent across all kinds.
class NotificationDeliveryRouter
  ROUTERS = {
    "comment_replied_to" => "NotificationDeliveryRouters::UserMentioned",
    "discussion_announced" => "NotificationDeliveryRouters::DiscussionEvent",
    "discussion_edited" => "NotificationDeliveryRouters::DiscussionEvent",
    "group_mentioned" => "NotificationDeliveryRouters::GroupMentioned",
    "invitation_accepted" => "NotificationDeliveryRouters::InvitationAccepted",
    "membership_created" => "NotificationDeliveryRouters::MembershipCreated",
    "membership_resent" => "NotificationDeliveryRouters::MembershipResent",
    "membership_request_approved" => "NotificationDeliveryRouters::MembershipRequestApproved",
    "membership_requested" => "NotificationDeliveryRouters::MembershipRequested",
    "new_coordinator" => "NotificationDeliveryRouters::NewCoordinator",
    "new_delegate" => "NotificationDeliveryRouters::NewDelegate",
    "new_discussion" => "NotificationDeliveryRouters::DiscussionEvent",
    "outcome_announced" => "NotificationDeliveryRouters::OutcomeAnnounced",
    "outcome_created" => "NotificationDeliveryRouters::OutcomeChange",
    "outcome_review_due" => "NotificationDeliveryRouters::OutcomeReviewDue",
    "outcome_updated" => "NotificationDeliveryRouters::OutcomeChange",
    "poll_closing_soon" => "NotificationDeliveryRouters::PollClosingSoon",
    "poll_edited" => "NotificationDeliveryRouters::PollEdited",
    "poll_expired" => "NotificationDeliveryRouters::PollExpired",
    "poll_announced" => "NotificationDeliveryRouters::PollAnnounced",
    "poll_reminder" => "NotificationDeliveryRouters::PollReminder",
    "reaction_created" => "NotificationDeliveryRouters::ReactionCreated",
    "unknown_sender" => "NotificationDeliveryRouters::UnknownSender",
    "user_added_to_group" => "NotificationDeliveryRouters::UserAddedToGroup",
    "user_mentioned" => "NotificationDeliveryRouters::UserMentioned"
  }.freeze

  attr_reader :notification, :subject_model

  def self.class_for(kind)
    router_name = ROUTERS[kind.to_s]
    raise ArgumentError, "no delivery router for #{kind.inspect}" unless router_name

    router_name.constantize
  end

  def self.for(notification)
    class_for(notification.kind).new(notification)
  end

  def initialize(notification)
    @notification = notification
    @subject_model = notification.subject_model
  end

  def translated_values(locale:)
    I18n.with_locale(locale) do
      values = translation_values.compact
      validate_translation_values!(values)
      values
    end
  end

  def route!
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

  def translation_values
    actor = notification.actor
    {
      name: actor.name,
      title: TranslationService.plain_text(subject_model.title_model, :title, actor),
      poll_type: (I18n.t("poll_types.#{subject_model.poll_type}") if subject_model.respond_to?(:poll_type))
    }
  end

  # Render the same translation selected by notification consumers so missing
  # router values fail when the notification is created, not during delivery.
  def validate_translation_values!(values)
    interpolation = values.merge(site_name: AppConfig.theme[:site_name])
    interpolation[:actor] = values[:name] if values.key?(:name)
    title_key = values[:title].present? ? "with_title" : "without_title"
    I18n.t("notifications.#{title_key}.#{notification.kind}", **interpolation)
  end

  # Subclasses select users and an optional volume source. This base class
  # applies channel filtering, complaint handling, and push subscription
  # expansion consistently for every notification kind.
  def recipients_by_channel
    raise NotImplementedError
  end

  # Selected users always receive in-app delivery. One optional volume source
  # narrows them for both external channels, while chatbot recipients remain separate.
  def recipients(users, volume: nil, chatbots: Chatbot.none)
    {
      "in_app" => users,
      "email" => recipients_with_volume(users, volume, :email),
      "push" => recipients_with_volume(users, volume, :push),
      "chatbot" => chatbots
    }
  end

  def recipients_with_volume(users, volume, channel)
    return User.none unless volume

    volume_enabled_users(volume, channel).where("users.id": users.select(:id))
  end

  # Topics and groups expose effective user volumes. Membership relations are
  # used for group mentions; user relations provide the account-default fallback.
  def volume_enabled_users(volume, channel)
    enabled_members_method = :"#{channel}_enabled_members"
    return volume.public_send(enabled_members_method) if volume.respond_to?(enabled_members_method)

    enabled_method = :"#{channel}_enabled"
    return User.where(id: volume.public_send(enabled_method).select(:user_id)) if volume.klass == Membership

    levels = User.public_send("volume_#{channel}_defaults").values_at("normal", "loud")
    volume.where("volume_#{channel}_default": levels)
  end

  # Transactional invitation resends are requested emails rather than app
  # notifications, so they intentionally bypass volume and have no app/push recipients.
  def transactional_email_only(email_recipients:)
    recipients(User.none).merge("email" => email_recipients)
  end

  def user_recipients
    User.where(id: notification.recipient_user_ids)
  end

  def recipient_context_ids(key)
    Array(notification.recipient_context[key]).map(&:to_i)
  end

  def translation_values_for(recipient)
    recipient = recipient.user if recipient.is_a?(PushSubscription)
    return notification.translation_values unless recipient.is_a?(User)

    translated_values(locale: recipient.locale)
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

  # Filter the completed email recipients once before creating delivery rows.
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

  def subject_topic
    subject = notification.subject
    return subject.topic if subject.is_a?(TopicItem)

    model = subject_model
    return model.topic if model.respond_to?(:topic) && model.topic
    return model.reactable.topic if model.respond_to?(:reactable) && model.reactable.respond_to?(:topic)
    model.reactable.parent.topic if model.respond_to?(:reactable) && model.reactable.respond_to?(:parent)
  end

  def subject_group
    model = subject_model
    if model.respond_to?(:group)
      model.group
    end
  end

  def subject_volume_source
    subject_topic || subject_group || User.active
  end
end
