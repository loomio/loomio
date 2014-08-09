class Events::NewComment < Event
  def self.publish!(comment)
    event = create!(kind: "new_comment",
                    eventable: comment,
                    discussion_id: comment.discussion.id)

    DiscussionReader.for(user: comment.author,
                         discussion: comment.discussion).follow!

    comment.mentioned_users.each do |mentioned_user|
      Events::UserMentioned.publish!(comment, mentioned_user)
    end

    comment.followers_without_mentioned_users_or_author.
            email_followed_threads.each do |follower|
        ThreadMailer.delay.new_comment(comment, follower)
    end

    event
  end

  def comment
    eventable
  end
end

