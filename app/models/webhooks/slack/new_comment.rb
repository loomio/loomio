class Webhooks::Slack::NewComment < Webhooks::Slack::Base

  def text
    I18n.t :"webhooks.slack.new_comment", author: author.name, name: discussion_link
  end

  def attachment_fallback
    "*#{eventable}*\n#{eventable}\n"
  end

  def attachment_title
  end

  def attachment_text
    "_#{eventable.body}_\n"
  end

  def attachment_fields
  end

  def attachment_color
    "#F6B936"
  end

  # private

  # def vote_position
  #   case eventable.position
  #   when "yes"
  #     "agreed on"
  #   when "no"
  #     "disagreed on"
  #   when "abstain"
  #     "abstained on"
  #   else
  #     "blocked"
  #   end
  # end

end