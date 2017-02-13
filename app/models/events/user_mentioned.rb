class Events::UserMentioned < Event
  attr_accessor :mentioned_user_id

  def self.publish!(model, actor, mentioned_user)
    create(kind: 'user_mentioned',
           eventable: model,
           mentioned_user_id: mentioned_user.id,
           user: actor,
           created_at: model.created_at).tap { |e| EventBus.broadcast('user_mentioned_event', e, mentioned_user) }
  end

  private

  def notification_recipients
    User.where(id: mentioned_user_id)
  end
end
