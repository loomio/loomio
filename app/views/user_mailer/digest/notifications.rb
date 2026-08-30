# frozen_string_literal: true

class Views::UserMailer::Digest::Notifications < Views::ApplicationMailer::Component
  def initialize(notifications:, recipient:)
    @notifications = notifications
    @recipient = recipient
  end

  def view_template
    section do
      h2 { plain t(:"notifications.header") }

      @notifications.each do |notification|
        context = NotificationRenderingContext.new(notification)
        path = notification.notification_url
        url = path.start_with?("/") ? "#{root_url.chomp('/')}#{path}" : path
        translation_values = notification.translation_values_for(@recipient.id)

        article do
          content = Views::UserMailer::Digest::NotificationContent.new(
            notification: notification,
            recipient: @recipient
          )
          render Views::NotificationMailer::Common::Notification.new(
            topic_item: context,
            recipient: @recipient,
            event_key: notification.kind,
            poll: context.poll,
            url: url,
            translation_values: translation_values,
            with_title: translation_values["title"].present?,
            content: content
          )
        end
      end
    end
  end
end
