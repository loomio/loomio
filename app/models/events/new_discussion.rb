class Events::NewDiscussion < Event
  def self.publish!(discussion)
    event = create!(kind: 'new_discussion',
                    eventable: discussion,
                    discussion_id: discussion.id)

    DiscussionReader.for(discussion: discussion,
                         user: discussion.author).follow!

    discussion.followers_without_author.each do |follower|
      if follower.email_followed_threads?
        ThreadMailer.delay.new_discussion(discussion, follower)
      end
    end

    event
  end

  def discussion
    eventable
  end
end
