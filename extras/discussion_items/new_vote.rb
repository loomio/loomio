class DiscussionItems::NewVote < DiscussionItem
  attr_reader :vote

  def initialize(vote)
    @vote = vote
  end

  def icon
    case vote.position
    when "yes"     then 'position-yes-icon'
    when "abstain" then 'position-abstain-icon'
    when "no"      then 'position-no-icon'
    when "block"   then 'position-block-icon'
    else
      'position-unvoted-icon'
    end
  end

  def actor
    vote.user
  end

  def header
    message = vote.position_to_s
    message += " (previously " + vote.previous_vote.position_to_s + ")" if vote.previous_vote
    message += vote.statement.blank? ? "." : ":"
    message
  end

  def group
    vote.discussion.group
  end

  def body
    return "" if vote.statement.blank?
    " #{vote.statement}"
  end

  def time
    vote.created_at
  end
end
