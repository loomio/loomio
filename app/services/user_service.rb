class UserService
  def self.delete_spam(user)
    Group.created_by(user).destroy_all
    user.destroy
  end

  def self.deactivate(user:, actor:, params:)
    actor.ability.authorize! :deactivate, user
    UserDeactivationResponse.create! user: user, body: params[:deactivation_response]
    user.deactivate!
    user
  end

  def self.update(user:, actor:, params:)
    actor.ability.authorize! :update, user
    user.update params
    user
  end
end
