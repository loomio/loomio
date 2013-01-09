class DiscussionItems::NewVote < DiscussionItem
  attr_reader :vote

  def initialize(vote)
    @vote = vote
  end

  def icon
    if vote.position
      return 'position-yes-icon' if vote.position == "yes"
      return 'position-abstain-icon' if vote.position == "abstain"
      return 'position-no-icon' if vote.position == "no"
      return 'position-block-icon' if vote.position == "block"
    else
      return 'position-unvoted-icon'
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
    "\"#{vote.statement}\""
  end

  def time
    vote.created_at
  end
end