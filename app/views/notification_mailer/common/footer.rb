# frozen_string_literal: true

class Views::NotificationMailer::Common::Footer < Views::ApplicationMailer::Component
  def initialize(topic_item:, recipient:, notification: nil, membership: nil, event_key:)
    @topic_item = topic_item
    @recipient = recipient
    @notification = notification
    @topic = topic_item.topic
    @membership = membership
    @event_key = event_key
  end

  def view_template
    div(class: "email-footer") do
      render_tracking_pixels
      render_footer_links if @recipient.is_logged_in?
      render_logo
    end
  end

  private

  def render_tracking_pixels
    if @notification
      img(
        src: mark_notification_as_read_pixel_src(@notification, recipient: @recipient),
        alt: "",
        width: 1,
        height: 1
      )
    end

    if @recipient.is_logged_in? && @topic && @topic_item.is_a?(TopicItem)
      img(
        src: pixel_src(@topic_item, recipient: @recipient),
        alt: "",
        width: 1,
        height: 1
      )
    end
  end

  def render_footer_links
    p do
      plain "\u2014"
      br
      span do
        raw t(
          :'discussion_mailer.reply_or_view_online_html',
          url: tracked_url(@topic_item.itemable, recipient: @recipient),
          hostname: AppConfig.theme[:site_name]
        )
      end
      br
      render_unsubscribe_link
    end
  end

  def render_unsubscribe_link
    reason_key, unsub_link = determine_unsubscribe_info
    return unless reason_key

    span { plain t(reason_key) }
    whitespace
    a(href: unsub_link) { plain t(:"common.action.unsubscribe") }
  end

  def determine_unsubscribe_info
    if @event_key == 'group_mentioned'
      [ "event_mailer.notification_reason.group_mentioned", unsubscribe_url(@topic_item.itemable, recipient: @recipient) ]
    elsif @event_key == 'user_mentioned' || @event_key == 'comment_replied_to'
      [ "event_mailer.notification_reason.user_mentioned", preferences_url(recipient: @recipient) ]
    elsif @notification&.recipient_user_ids&.include?(@recipient.id)
      [ "event_mailer.notification_reason.notified", unsubscribe_url(@topic_item.itemable, recipient: @recipient) ]
    elsif @membership&.volume_email == 'loud'
      [ "event_mailer.notification_reason.group_subscribed", unsubscribe_url(@topic_item.itemable, recipient: @recipient) ]
    elsif @topic && TopicReader.for(user: @recipient, topic: @topic).volume_email == 'loud'
      [ "event_mailer.notification_reason.thread_subscribed", unsubscribe_url(@topic_item.itemable, recipient: @recipient) ]
    end
  end

  def render_logo
    image_tag(
      AppConfig.theme[:email_footer_logo_src],
      height: 24,
      alt: "Logo",
      class: "email-footer-logo"
    )
  end
end
