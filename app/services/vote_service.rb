class VoteService
  def self.create(vote:, actor:)
    vote.author = actor
    actor.ability.authorize! :create, vote
    return false unless vote.valid?
    vote.save!

    EventBus.broadcast('vote_create', vote, actor)
    Events::NewVote.publish!(vote)
  end
end
