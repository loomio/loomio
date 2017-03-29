class Slack::PollClosingSoonSerializer < Slack::BaseSerializer

  def attachment_fallback
    "*#{model.title}*\n#{model.details}\n"
  end

  def attachment_title
    slack_link_for(model)
  end

  def attachment_text
    model.details
  end

  private

  def text_options
    { name: slack_link_for(model.discussion) }
  end

end
