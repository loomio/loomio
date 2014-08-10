class Events::UserMentioned < Event
  def self.publish!(comment, mentioned_user)
    event = create!(kind: "user_mentioned", eventable: comment, user: mentioned_user)

    discussion_reader = DiscussionReader.for(discussion: comment.discussion,
                                             user: mentioned_user)

    unless discussion_reader.following?
      if mentioned_user.email_when_mentioned?
        UserMailer.delay.mentioned(mentioned_user, comment)
      end

      discussion_reader.follow!
    end

    notify!(mentioned_user)

    event
  end

  def comment
    eventable
  end

  def mentioned_user
    user
  end
end
