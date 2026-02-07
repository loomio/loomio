# frozen_string_literal: true

class Views::Email::ReceivedEmailMailer < Views::Email::EventLayout

  def initialize(event:, recipient:, event_key:)
    @event = event
    @recipient = recipient
    @event_key = event_key
  end

  def view_template
    group = @event.eventable.group
    url = group_emails_url(@event.eventable.group.key)

    render Views::Email::Group::CoverAndLogo.new(group: group)
    render Views::Email::Common::Notification.new(
      event: @event,
      recipient: @recipient,
      event_key: @event_key,
      with_title: true,
      url: url,
      message: @event.eventable.title
    )

    div(class: "text-center") do
      render Views::Email::Common::Button.new(
        url: url,
        text: t(:"email_to_group.review_email")
      )
    end

    raw t('event_mailer.received_email.explaination_html', group: group.full_name)

    render Views::Email::Common::Footer.new(
      event: @event,
      recipient: @recipient,
      event_key: @event_key
    )
  end
end
