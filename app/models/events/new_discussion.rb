class Events::NewDiscussion < Event
  def self.publish!(discussion)
    event = create!(kind: 'new_discussion',
                    eventable: discussion)

    group = discussion.group
    DiscussionReader.for(discussion: discussion,
                         user: discussion.author).follow!

    discussion.followers_without_author.
               email_followed_threads.each do |user|
      ThreadMailer.delay.new_discussion(user, event)
    end

    discussion.followers_without_author.
               dont_email_followed_threads.
               email_new_discussions_for(group).uniq.each do |user|
      ThreadMailer.delay.new_discussion(user, event)
    end

    discussion.group_members_not_following.
               email_new_discussions_for(group).uniq.each do |user|
      ThreadMailer.delay.new_discussion(user, event)
    end

    event
  end

  def discussion
    eventable
  end
end
