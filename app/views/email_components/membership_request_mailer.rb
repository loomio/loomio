# frozen_string_literal: true

class Views::EmailComponents::MembershipRequestMailer < Views::Base
  include Phlex::Rails::Helpers::T
  include EmailHelper

  def initialize(event:, recipient:, event_key:, utm_hash: {})
    @event = event
    @recipient = recipient
    @event_key = event_key
    @utm_hash = utm_hash
  end

  def view_template
    group = @event.eventable.group
    url = group_membership_requests_url(group, @utm_hash)

    render Views::EmailComponents::Group::CoverAndLogo.new(group: group)
    render Views::EmailComponents::Common::Notification.new(
      event: @event,
      recipient: @recipient,
      event_key: @event_key,
      with_title: true,
      url: url,
      message: @event.eventable.introduction
    )

    div(class: "text-center") do
      render Views::EmailComponents::Common::Button.new(
        url: url,
        text: t(:"email.membership_request.button_text")
      )
    end

    render Views::EmailComponents::Common::Footer.new(
      event: @event,
      recipient: @recipient,
      event_key: @event_key
    )
  end
end
