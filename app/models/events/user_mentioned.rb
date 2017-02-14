class Events::UserMentioned < Event
  include Events::NotifyUser
  include Events::EmailUser

  def self.publish!(model, actor, mentioned_user)
    create(kind: 'user_mentioned',
           eventable: model,
           user: actor,
           created_at: model.created_at).tap { |e| EventBus.broadcast('user_mentioned_event', e, mentioned_user.id) }           
  end
end
