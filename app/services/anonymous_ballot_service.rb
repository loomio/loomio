class AnonymousBallotService
  def self.create(anonymous_ballot:, actor:)
    poll = anonymous_ballot.poll
    actor.ability.authorize!(:vote_in, poll)
    raise CanCan::AccessDenied unless poll.detached_anonymous?

    voter = poll.anonymous_poll_voters.find_by!(voter_id: actor.id)

    AnonymousBallot.transaction do
      voter.lock!
      raise CanCan::AccessDenied if voter.ballot_submitted?
      raise CanCan::AccessDenied unless poll.reload.active?

      anonymous_ballot.save!
      voter.update_columns(ballot_submitted: true)
      poll.update_counts!
    end

    true
  end
end
