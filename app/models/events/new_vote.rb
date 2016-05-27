class Events::NewVote < Event
  def self.publish!(vote)
    create(kind: 'new_vote',
           eventable: vote,
           discussion: vote.motion.discussion,
           created_at: vote.created_at).tap { |e| EventBus.broadcast('new_vote_event', e) }
  end
end
