class Webhooks::Slack::NewMotion < Webhooks::Slack::Base

  def text
    I18n.t :"webhooks.slack.new_motion", author: author.name, name: discussion_link
  end

  def attachment_fallback
    "*#{eventable.name}*\n#{eventable.description}\n"
  end

  def attachment_title
    proposal_link(eventable)
  end

  def attachment_text
    "#{eventable.description}\n"
  end

  def attachment_fields
    [motion_vote_field]
  end

end
