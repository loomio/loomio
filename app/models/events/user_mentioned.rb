class Events::UserMentioned < Event
  def self.publish!(comment, mentioned_user)
    event = create!(kind: 'user_mentioned',
                    eventable: comment,
                    user: comment.author,
                    created_at: comment.created_at)


    if mentioned_user.email_when_mentioned?
      ThreadMailer.delay.user_mentioned(mentioned_user, event)
    end

    event.notify!(mentioned_user)

    event
  end

  def comment
    eventable
  end
end
