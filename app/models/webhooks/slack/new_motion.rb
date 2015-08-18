class Webhooks::Slack::NewMotion < Webhooks::Slack::Base

  def attachment_fallback
    "*#{eventable.name}*\n#{eventable.description}\n"
  end

  def attachment_title
    eventable.name
  end

  def attachment_text
    "#{eventable.description}\n"
  end

  def attachment_fields
    [motion_vote_field]
  end

end
