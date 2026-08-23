# frozen_string_literal: true

class Views::DeliveryMailer::MembershipRequest < Views::DeliveryMailer::Layout

  def initialize(topic_item:, recipient:, event_key:, utm_hash: {})
    @topic_item = topic_item
    @recipient = recipient
    @event_key = event_key
    @utm_hash = utm_hash
  end

  def view_template
    group = @topic_item.itemable.group
    url = group_membership_requests_url(group, @utm_hash)

    render Views::DeliveryMailer::Group::CoverAndLogo.new(group: group)
    render Views::DeliveryMailer::Common::Notification.new(
      topic_item: @topic_item,
      recipient: @recipient,
      event_key: @event_key,
      with_title: true,
      url: url,
      message: @topic_item.itemable.introduction
    )

    div(class: "text-center") do
      render Views::DeliveryMailer::Common::Button.new(
        url: url,
        text: t(:"email.membership_request.button_text")
      )
    end

    render Views::DeliveryMailer::Common::Footer.new(
      topic_item: @topic_item,
      recipient: @recipient,
      event_key: @event_key
    )
  end
end
