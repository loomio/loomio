class Events::UserMentioned < Event
  def self.publish!(comment, mentioned_user)
    event = create!(kind: 'user_mentioned',
                    eventable: comment,
                    discussion: comment.discussion,
                    user: mentioned_user,
                    created_at: comment.created_at)

    DiscussionReader.for(discussion: comment.discussion,
                         user: mentioned_user).follow!

    # in app notification
    event.notify!(mentioned_user)

    # we don't email anything. New comment will handle that

    event
  end

  def comment
    eventable
  end
end
