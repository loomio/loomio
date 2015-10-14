class Webhooks::Slack::MotionClosed < Webhooks::Slack::Base

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
    [view_motion_on_loomio]
  end
  
end
