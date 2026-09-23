# frozen_string_literal: true

class Views::Polls::Export < Views::Application::Component
  include EmailHelper

  def initialize(poll:, exporter:, recipient:)
    @poll = poll
    @exporter = exporter
    @recipient = recipient
  end

  def view_template
    style { plain email_theme_css }
    stylesheet_link_tag "email"
    main(class: "email-body") do
      render Views::NotificationMailer::Common::Title.new(itemable: @poll, recipient: @recipient)
      render Views::NotificationMailer::Common::Tags.new(itemable: @poll)
      render Views::NotificationMailer::Poll::Summary.new(poll: @poll, recipient: @recipient)
      render Views::NotificationMailer::Poll::VotingPeriod.new(poll: @poll, recipient: @recipient)
      render Views::NotificationMailer::Poll::Vote.new(poll: @poll, recipient: @recipient)
      render Views::NotificationMailer::Poll::Rules.new(poll: @poll)
      render Views::NotificationMailer::Poll::ResultsPanel.new(poll: @poll, current_user: @recipient)
      render Views::NotificationMailer::Poll::Responses.new(topic_item: @poll.created_topic_item, recipient: @recipient)
    end
  end
end
