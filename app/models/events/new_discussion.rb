class Events::NewDiscussion < Event
  def self.publish!(discussion)
    event = create!(kind: 'new_discussion',
                    eventable: discussion,
                    discussion_id: discussion.id)

    group = discussion.group
    DiscussionReader.for(discussion: discussion,
                         user: discussion.author).follow!

    discussion.followers_without_author.
               email_followed_threads.each do |user|
      ThreadMailer.delay.new_discussion(user, discussion)
    end

    discussion.followers_without_author.
               dont_email_followed_threads.
               email_new_discussions_for(group).each do |user|
      ThreadMailer.delay.new_discussion(user, discussion)
    end

    discussion.group_members_not_following.
               email_new_discussions_for(group).each do |user|
      ThreadMailer.delay.new_discussion(user, discussion)
    end

    event
  end

  def discussion
    eventable
  end
end
