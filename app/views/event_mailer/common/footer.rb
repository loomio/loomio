# frozen_string_literal: true

class Views::EventMailer::Common::Footer < Views::BaseMailer::Base

  def initialize(event:, recipient:, notification: nil, discussion: nil, poll: nil, membership: nil, event_key:)
    @event = event
    @recipient = recipient
    @notification = notification
    @discussion = discussion
    @poll = poll
    @membership = membership
    @event_key = event_key
  end

  def view_template
    div(class: "thread-mailer__footer") do
      render_tracking_pixels
      render_footer_links if @recipient.is_logged_in?
      render_logo
    end
  end

  private

  def render_tracking_pixels
    if @notification
      img(
        class: "thread-mailer__footer-image",
        src: mark_notification_as_read_pixel_src(@notification, recipient: @recipient),
        alt: "",
        width: 1,
        height: 1
      )
    end

    if @recipient.is_logged_in? && @discussion
      img(
        class: "thread-mailer__footer-image",
        src: pixel_src(@event, recipient: @recipient),
        alt: "",
        width: 1,
        height: 1
      )
    end
  end

  def render_footer_links
    p(class: "thread-mailer__footer-links") do
      plain "\u2014"
      br
      span(class: "reply-or-view-online") do
        raw t(
          :'discussion_mailer.reply_or_view_online_html',
          url: tracked_url(@event.eventable, recipient: @recipient),
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

    span(class: "notification-reason") { plain t(reason_key) }
    whitespace
    a(class: "unsubscribe-link", href: unsub_link) { plain t(:"common.action.unsubscribe") }
  end

  def determine_unsubscribe_info
    if @event_key == 'group_mentioned'
      ["event_mailer.notification_reason.group_mentioned", unsubscribe_url(@event.eventable, recipient: @recipient)]
    elsif @event_key == 'user_mentioned' || @event_key == 'comment_replied_to'
      ["event_mailer.notification_reason.user_mentioned", preferences_url(recipient: @recipient)]
    elsif @event.all_recipient_user_ids.include?(@recipient.id)
      ["event_mailer.notification_reason.notified", unsubscribe_url(@event.eventable, recipient: @recipient)]
    elsif @membership&.volume == 'loud'
      ["event_mailer.notification_reason.group_subscribed", unsubscribe_url(@event.eventable, recipient: @recipient)]
    elsif @discussion && ::DiscussionReader.for(user: @recipient, discussion: @discussion).volume == 'loud'
      ["event_mailer.notification_reason.discussion_subscribed", unsubscribe_url(@event.eventable, recipient: @recipient)]
    elsif @poll && @poll.stances.latest.find_by(participant_id: @recipient.id)&.volume == 'loud'
      ["event_mailer.notification_reason.poll_subscribed", unsubscribe_url(@event.eventable, recipient: @recipient)]
    end
  end

  def render_logo
    image_tag(
      AppConfig.theme[:email_footer_logo_src],
      height: 24,
      alt: "Logo",
      class: "thread-mailer__footer-logo"
    )
  end
end
