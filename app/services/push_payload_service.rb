class PushPayloadService
  include ActionView::Helpers::SanitizeHelper

  def self.for_notification(notification:, recipient:)
    values = notification.translation_values_for(recipient.id).symbolize_keys
    new(
      kind: notification.kind,
      actor: notification.actor,
      values: values,
      url: notification.notification_url,
      tag: "notification-#{notification.id}"
    ).payload
  end

  def self.for_topic_item(topic_item:, recipient:)
    itemable = topic_item.itemable
    values = {
      name: topic_item.user.name,
      title: TranslationService.plain_text(itemable.title_model, :title, recipient),
      poll_type: (I18n.t("poll_types.#{itemable.poll_type}") if itemable.respond_to?(:poll_type))
    }.compact
    new(
      kind: topic_item.kind,
      actor: topic_item.actor,
      values: values,
      url: topic_item.notification_url,
      tag: "topic-item-#{topic_item.id}"
    ).payload
  end

  def self.for_test
    {
      title: I18n.t("push_notifications.title"),
      body: I18n.t("push_notifications.enabled"),
      icon: AppConfig.theme[:icon192_src],
      badge: AppConfig.theme[:favicon32_src],
      tag: "push-notification-test",
      data: { url: "/email_preferences" }
    }
  end

  def initialize(kind:, actor:, values:, url:, tag:)
    @kind = kind
    @actor = actor
    @values = values
    @url = url
    @tag = tag
  end

  def payload
    interpolation = values.merge(
      actor: actor&.name || values[:name],
      site_name: AppConfig.theme[:site_name]
    )
    key = values[:title].present? ? "notifications.with_title.#{kind}" : "notifications.without_title.#{kind}"
    body = I18n.t(key, default: values[:title] || AppConfig.theme[:site_name], **interpolation)

    {
      title: values[:title].presence || AppConfig.theme[:site_name],
      body: strip_tags(body),
      icon: AppConfig.theme[:icon192_src],
      badge: AppConfig.theme[:favicon32_src],
      tag: tag,
      data: { url: url }
    }
  end

  private

  attr_reader :kind, :actor, :values, :url, :tag
end
