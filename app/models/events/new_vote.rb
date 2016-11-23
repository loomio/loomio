class Events::NewVote < Event
  def self.publish!(vote)
    create(kind: 'new_vote',
           eventable: vote,
           discussion_id: vote.discussion_id,
           created_at: vote.created_at).tap { |e| EventBus.broadcast('new_vote_event', e) }
  end
end
