class VoteService
  def self.create(vote: vote, actor: actor)
    vote.author = actor
    return false unless vote.valid?
    actor.ability.authorize! :create, vote
    vote.save!
    Events::NewVote.publish!(vote)
  end
end
