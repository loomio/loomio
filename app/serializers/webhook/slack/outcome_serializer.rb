class Webhook::Slack::OutcomeSerializer < Webhook::Slack::PollSerializer
  def body
    if eventable.statement_format == 'html'
      ReverseMarkdown.convert(eventable.statement)
    else
      eventable.statement
    end
  end

  def body_format
    statement_format
  end
end
