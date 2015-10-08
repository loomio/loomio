class Events::NewVote < Event
  def self.publish!(vote)
    event = create!(kind: 'new_vote',
                    eventable: vote,
                    discussion: vote.motion.discussion,
                    created_at: vote.created_at)

    BaseMailer.send_bulk_mail(to: UsersToEmailQuery.new_vote(vote)) do |user|
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
