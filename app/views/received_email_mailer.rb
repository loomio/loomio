# frozen_string_literal: true

class Views::ReceivedEmailMailer < Views::DeliveryMailer::Layout

  def initialize(topic_item:, recipient:, event_key:)
    @topic_item = topic_item
    @recipient = recipient
    @event_key = event_key
  end

  def view_template
    group = @topic_item.itemable.group
    url = group_emails_url(@topic_item.itemable.group.key)

    render Views::DeliveryMailer::Group::CoverAndLogo.new(group: group)
    render Views::DeliveryMailer::Common::Notification.new(
      topic_item: @topic_item,
      recipient: @recipient,
      event_key: @event_key,
      with_title: true,
      url: url,
      message: @topic_item.itemable.title
    )

    div(class: "text-center") do
      render Views::DeliveryMailer::Common::Button.new(
        url: url,
        text: t(:"email_to_group.review_email")
      )
    end

    raw t('event_mailer.received_email.explaination_html', group: group.full_name)

    render Views::DeliveryMailer::Common::Footer.new(
      topic_item: @topic_item,
      recipient: @recipient,
      event_key: @event_key
    )
  end
end
