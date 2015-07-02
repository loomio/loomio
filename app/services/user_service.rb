class UserService
  def self.delete_spam(user)
    Group.created_by(user).destroy_all
    user.destroy
  end

  def self.deactivate(user:, actor:, params:)
    actor.ability.authorize! :deactivate, user
    UserDeactivationResponse.create(user: user, body: params[:deactivation_response])
    user.deactivate!
    user
  end

  def self.update(user:, actor:, params:)
    actor.ability.authorize! :update, user
    user.update params
    user
  end

  def self.change_password(user:, actor:, params:)
    actor.ability.authorize! :update, user
    user.errors.add :current_password, I18n.t(:"error.current_password_did_not_match") unless user.valid_password? params.delete(:current_password)
    user.errors.add :password, I18n.t(:"error.passwords_did_not_match")                unless params[:password] == params[:password_confirmation]
    if user.errors.empty?
      user.update params
      yield if block_given?
    end
    user
  end
end
