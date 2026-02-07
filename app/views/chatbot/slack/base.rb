# frozen_string_literal: true

class Views::Chatbot::Slack::Base < Views::Chatbot::Base
  private

  def md(text)
    raw safe(text.to_s)
  end

  def sd(text)
    raw safe(SlackMrkdwn.from(text.to_s))
  end

  def slack_convert(&block)
    sd(capture(&block))
  end
end
