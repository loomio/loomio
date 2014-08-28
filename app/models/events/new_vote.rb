class Events::NewVote < Event
  def self.publish!(vote)
    event = create!(kind: 'new_vote',
                    eventable: vote,
                    discussion: vote.motion.discussion)

    DiscussionReader.for(discussion: vote.motion.discussion,
                         user: vote.author).follow!

    vote.motion_followers_without_voter.
         email_followed_threads.each do |user|
      ThreadMailer.delay.new_vote(user, event)
    end

    event
  end

  def vote
    eventable
  end
end
