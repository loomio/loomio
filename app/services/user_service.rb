class UserService
  def self.delete_spam(user)
    Group.created_by(user).destroy_all
    user.destroy
    EventBus.broadcast('user_delete_spam', user)
  end

  def self.deactivate(user:, actor:, params:)
    actor.ability.authorize! :deactivate, user
    user.deactivate!
    EventBus.broadcast('user_deactivate', user, actor, params)
  end

  def self.update(user:, actor:, params:)
    actor.ability.authorize! :update, user
    user.update params
    EventBus.broadcast('user_update', user, actor, params)
  end

  def self.change_password(user:, actor:, params:)
    actor.ability.authorize! :update, user
    user.errors.add :current_password, I18n.t(:"error.current_password_did_not_match") unless user.valid_password? params.delete(:current_password)
    user.errors.add :password, I18n.t(:"error.passwords_did_not_match")                unless params[:password] == params[:password_confirmation]

    return false unless user.errors.empty?
    user.assign_attributes(params.slice(:password))
    user.save

    yield if block_given? and user.errors.empty?
    EventBus.broadcast('user_change_password', user, actor, params)
  end
end
