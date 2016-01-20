class Events::UserMentioned < Event
  def self.publish!(comment, mentioned_user)
    create(kind: 'user_mentioned',
           eventable: comment,
           user: comment.author,
           created_at: comment.created_at).tap { |e| EventBus.broadcast('user_mentioned_event', e, mentioned_user) }
  end

  def comment
    eventable
  end
end
