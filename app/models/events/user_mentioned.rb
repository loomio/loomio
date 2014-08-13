class Events::UserMentioned < Event
  def self.publish!(comment, mentioned_user)
    # create event
    # enfollow mentioned user
    # In app notifcaiton
    # return event
    
    event = create!(kind: "user_mentioned", eventable: comment, user: mentioned_user)

    DiscussionReader.for(discussion: comment.discussion,
                         user: mentioned_user).follow!

    # in app notification
    event.notify!(mentioned_user)

    event
  end

  def comment
    eventable
  end

  def mentioned_user
    user
  end
end
