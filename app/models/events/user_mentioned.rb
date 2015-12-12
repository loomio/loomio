class Events::UserMentioned < Event
  def self.publish!(comment, mentioned_user)
    create!(kind: 'user_mentioned',
            eventable: comment,
            user: comment.author,
            created_at: comment.created_at).tap do |event|
      event.notify!(mentioned_user)
      EventBus.instance.broadcast('user_mentioned', event, mentioned_user)
    end
  end

  def comment
    eventable
  end
end
