# Defines the common lifecycle for turning one logical notification occurrence
# into channel-specific deliveries. Each notification kind owns only its
# audience and occurrence rules in a subclass; insertion, retry safety, and
# dispatch remain consistent across all kinds.
class NotificationDeliveryResolver
  RESOLVERS = {
    "comment_replied_to" => "NotificationDeliveryResolvers::CommentRepliedTo",
    "discussion_announced" => "NotificationDeliveryResolvers::DiscussionAnnounced",
    "discussion_edited" => "NotificationDeliveryResolvers::DiscussionEdited",
    "group_mentioned" => "NotificationDeliveryResolvers::GroupMentioned",
    "invitation_accepted" => "NotificationDeliveryResolvers::InvitationAccepted",
    "membership_created" => "NotificationDeliveryResolvers::MembershipCreated",
    "membership_resent" => "NotificationDeliveryResolvers::MembershipResent",
    "membership_request_approved" => "NotificationDeliveryResolvers::MembershipRequestApproved",
    "membership_requested" => "NotificationDeliveryResolvers::MembershipRequested",
    "new_coordinator" => "NotificationDeliveryResolvers::NewCoordinator",
    "new_delegate" => "NotificationDeliveryResolvers::NewDelegate",
    "new_discussion" => "NotificationDeliveryResolvers::NewDiscussion",
    "outcome_announced" => "NotificationDeliveryResolvers::OutcomeAnnounced",
    "outcome_created" => "NotificationDeliveryResolvers::OutcomeCreated",
    "outcome_review_due" => "NotificationDeliveryResolvers::OutcomeReviewDue",
    "outcome_updated" => "NotificationDeliveryResolvers::OutcomeUpdated",
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

  def self.deduplication_key(_subject, occurrence_key: nil)
    raise NotImplementedError
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

    recipients = recipients_by_channel
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

  def recipients_by_channel
    raise NotImplementedError
  end

  def explicit_users
    User.where(id: notification.recipient_user_ids)
  end

  def explicit_chatbots
    Chatbot.where(id: notification.recipient_chatbot_ids)
  end

  def translation_values_for(recipient)
    return notification.translation_values unless recipient.is_a?(User)

    self.class.translation_values(
      notification.subject,
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
      end
    end
  end
end
