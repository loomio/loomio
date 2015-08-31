class VoteService
  def self.create(vote:, actor:)
    vote.author = actor
    return false unless vote.valid?
    actor.ability.authorize! :create, vote
    vote.save!

    event = Events::NewVote.publish!(vote)
    DiscussionReader.for(discussion: vote.motion.discussion, user: actor).author_thread_item!(vote.created_at)
    event
  end
end
