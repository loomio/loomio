# frozen_string_literal: true

class Views::Chatbot::Matrix::Notification < Views::Chatbot::Base
  def initialize(event:, poll: nil, recipient: nil)
    @event = event
    @poll = poll
    @recipient = recipient
  end

  def view_template
    title = capture { link_to(@event.eventable.title, polymorphic_url(@event.eventable)) }
    poll_type = @poll ? t("poll_types.#{@poll.poll_type}") : nil

    raw t("notifications.with_title.#{@event.kind}", actor: @event.user.name, title: title, poll_type: poll_type, site_name: AppConfig.theme[:site_name]).html_safe

    if @poll
      render Views::Chatbot::Matrix::Undecided.new(poll: @poll)
    end
  end
end
