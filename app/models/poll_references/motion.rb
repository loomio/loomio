class PollReferences::Motion < PollReferences::Base
  def initialize(motion)
    @motion = motion
  end

  def communities
    if @motion.voting?
      [@motion.group.community]
    else
      [Communities::LoomioUsers.new(
        loomio_user_ids: @motion.did_not_voters.pluck(:id) + @motion.votes.pluck(:user_id).uniq
      )]
    end
  end

  def references
    [
      PollReference.new(reference: @motion),
      PollReference.new(reference: @motion.discussion),
      PollReference.new(reference: @motion.group)
    ]
  end
end
