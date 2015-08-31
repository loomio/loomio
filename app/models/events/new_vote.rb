class Events::NewVote < Event
  def self.publish!(vote)
    event = create!(kind: 'new_vote',
                    eventable: vote,
                    discussion: vote.motion.discussion,
                    created_at: vote.created_at)

    UsersToEmailQuery.new_vote(vote).find_each do |user|
      ThreadMailer.delay.new_vote(user, event)
    end

    event
  end

  def group_key
    discussion.group.key
  end

  def vote
    eventable
  end
end
