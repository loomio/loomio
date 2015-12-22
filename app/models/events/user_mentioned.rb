class Events::UserMentioned < Event
  def self.publish!(comment, mentioned_user)
    create(kind: 'user_mentioned',
           eventable: comment,
           user: comment.author,
           created_at: comment.created_at).tap { |e| Loomio::EventBus.broadcast('user_mentioned_event', mentioned_user, e) }
  end

  def comment
    eventable
  end
end
