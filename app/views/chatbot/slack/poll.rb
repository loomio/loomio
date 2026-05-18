# frozen_string_literal: true

class Views::Chatbot::Slack::Poll < Views::Chatbot::Slack::Base
  include Views::Chatbot::Markdown::Concerns
  include Views::Chatbot::Slack::Concerns

  def initialize(event:, poll:, recipient:)
    @event = event
    @poll = poll
    @recipient = recipient
  end

  def view_template
    slack_convert { render_notification_text(@event, @poll) }
    md "\n"
    slack_convert { render_title(@poll) }
    md "\n"
    slack_convert { render_outcome(@poll) }
    md "\n"
    slack_convert { render_body(@poll) }
    md "\n"
    md "\n"
    slack_convert { render_voting_period(@poll) }
    md "\n"
    slack_convert { render_vote(@poll) }
    md "\n"
    md "\n"
    slack_convert { render_rules(@poll) }
    md "\n"
    md "\n"
    render_slack_results(@poll)
  end
end
