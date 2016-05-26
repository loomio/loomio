class Events::UserMentioned < Event
  def self.publish!(model, mentioned_user)
    create(kind: 'user_mentioned',
           eventable: model,
           user: model.author,
           created_at: model.created_at).tap { |e| EventBus.broadcast('user_mentioned_event', e, mentioned_user) }
  end

  def comment
    eventable
  end
end
