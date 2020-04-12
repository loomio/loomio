class Webhook::OutcomeSerializer < Webhook::PollSerializer
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

  def text_options
    super.merge(poll_type: I18n.t("poll_types.#{object.eventable.poll.poll_type}"))
  end
end
