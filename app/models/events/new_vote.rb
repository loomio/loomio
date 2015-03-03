class Events::NewVote < Event
  def self.publish!(vote)
    event = create!(kind: 'new_vote',
                    eventable: vote,
                    discussion: vote.motion.discussion,
                    created_at: vote.created_at)

    if vote.author.email_on_participation?
      DiscussionReader.for(discussion: vote.motion.discussion,
                           user:       vote.author).change_volume! :email
    end

    ThreadMailerQuery.users_to_email_new_vote(vote).each do |user|
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
