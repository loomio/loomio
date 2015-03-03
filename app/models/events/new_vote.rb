class Events::NewVote < Event
  def self.publish!(vote)
    event = create!(kind: 'new_vote',
                    eventable: vote,
                    discussion: vote.motion.discussion,
                    created_at: vote.created_at)

    DiscussionReader.for(discussion: vote.motion.discussion,
                         user: vote.author).
                     set_volume_as_required!

    UsersToEmailQuery.new_vote(vote).find_each do |user|
      ThreadMailer.delay.new_vote(user, event)
    end

    event
  end

  def vote
    eventable
  end

  def message_channel
    "/discussion-#{vote.motion.discussion.key}" #/#{kind}"
  end
end
