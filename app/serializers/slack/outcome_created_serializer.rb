class Slack::OutcomeCreatedSerializer < Slack::BaseSerializer

  def attachment_fallback
    "*#{model.poll.title}*\n#{model.statement}\n"
  end

  def attachment_title
    slack_link_for(model)
  end

  def attachment_text
    model.statement
  end

  private

  def text_options
    {
      author: slack_link_for(model.author),
      name:   slack_link_for(model)
    }
  end

end
