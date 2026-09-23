class AnonymousBallotService
  def self.create(anonymous_ballot:, actor:)
    poll = anonymous_ballot.poll
    actor.ability.authorize!(:vote_in, poll)
    raise CanCan::AccessDenied unless poll.detached_anonymous?

    AnonymousBallot.transaction do
      poll.lock!
      raise CanCan::AccessDenied unless poll.active?

      voter = poll.anonymous_poll_voters.find_by!(voter_id: actor.id)
      voter.lock!
      raise CanCan::AccessDenied if voter.ballot_submitted?

      anonymous_ballot.save!
      voter.update_columns(ballot_submitted: true)
      poll.update_counts!
    end

    anonymous_ballot
  end
end
