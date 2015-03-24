class UserService
  def self.update(user:, actor:, params:)
    actor.ability.authorize! :update, user
    user.update! params
    user
  end
end
