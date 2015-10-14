class Webhooks::Slack::NewVote < Webhooks::Slack::Base

  def text
    I18n.t :"webhooks.slack.new_vote", author: author.name, position: vote_position, name: discussion_link, proposal: proposal_link(eventable)
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
    when "yes"
      "#94D587"
    when "no"
      "#D1908F"
    when "abstain"
      "#EEBC57"
    else
      "#D80D00"
    end
  end

  private

  def vote_position
    case eventable.position
    when "yes"
      "agreed on"
    when "no"
      "disagreed on"  
    when "abstain"
      "abstained on"
    else
      "blocked"
    end
  end

end