class NewVoteActivityItem
  attr_reader :position, :group, :actor, :header, :body, :time

  def initialize(vote)
    @position, @group, @actor, @header, @body, @time = vote.position, vote.discussion.group,
      vote.user, position_message(vote), position_activity_body(vote.statement),
      vote.created_at
  end

  def icon
    'position-icon'
  end

  def position_message(vote)
    message = vote.position_to_s
    if vote.previous_vote
      message += " (previously " + vote.previous_vote.position_to_s + ")"
    end
    message += vote.statement.blank? ? "." : ":"
    message
  end

  def position_activity_body(body)
    body.blank? ? "" : "'#{body}'"
  end
end