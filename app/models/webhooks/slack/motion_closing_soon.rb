class Webhooks::Slack::MotionClosingSoon < Webhooks::Slack::Base

  def attachment_fallback
    "*#{eventable.name}*\n#{eventable.description}\n"
  end

  def attachment_title
    proposal_link(eventable)
  end

  def attachment_text
    eventable.description
  end

  def attachment_fields
    [motion_vote_field]
  end

end
