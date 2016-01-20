class VoteService
  def self.create(vote:, actor:)
    actor.ability.authorize! :create, vote
    vote.author = actor

    return false unless vote.valid?
    vote.save!

    EventBus.broadcast('vote_create', vote, actor)
    Events::NewVote.publish!(vote)
  end
end
