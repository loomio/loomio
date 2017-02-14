class Events::NewVote < Event
  include Events::LiveUpdate
  include Events::EmailUser
  include Events::JoinDiscussion

  def self.publish!(vote)
    create(kind: 'new_vote',
           eventable: vote,
           discussion: vote.motion.discussion,
           created_at: vote.created_at).tap { |e| EventBus.broadcast('new_vote_event', e) }
  end

  private

  def email_recipients
    Queries::UsersByVolumeQuery.loud(eventable.motion.discussion)
                               .without(eventable.author)
  end
end
