class Webhooks::Slack::NewVote < Webhooks::Slack::Base

  def text
    I18n.t :"webhooks.slack.new_vote", author: author.name, position: vote_position, proposal: proposal_link(eventable), name: discussion_link
  end

  def attachment_fallback
    "*#{eventable.position}*\n#{eventable.statement}\n"
  end

  def attachment_title
  end

  def attachment_text
    "#{eventable.statement}\n"
  end

  def attachment_fields
  end

  def attachment_color
    case eventable.position
    when "yes" then SiteSettings.colors[:agree]
    when "no" then SiteSettings.colors[:disagree]
    when "abstain" then SiteSettings.colors[:abstain]
    else SiteSettings.colors[:block]
    end
  end

  def vote_position
    I18n.t :"webhooks.slack.position_verbs.#{eventable.position}"
  end

end
