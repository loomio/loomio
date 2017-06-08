class UserService
  def self.delete_spam(user)
    Group.where(creator_id: user.id).destroy_all
    user.destroy
    EventBus.broadcast('user_delete_spam', user)
  end

  def self.deactivate(user:, actor:, params:)
    actor.ability.authorize! :deactivate, user
    user.deactivate!
    EventBus.broadcast('user_deactivate', user, actor, params)
  end

  def self.set_volume(user:, actor:, params:)
    actor.ability.authorize! :update, user
    user.update!(default_membership_volume: params[:volume])
    if params[:apply_to_all]
      user.memberships.update_all(volume: Membership.volumes[params[:volume]])
      user.discussion_readers.update_all(volume: nil)
    end
    EventBus.broadcast('user_set_volume', user, actor, params)
  end

  def self.update(user:, actor:, params:)
    actor.ability.authorize! :update, user
    user.update params
    EventBus.broadcast('user_update', user, actor, params)
  end

  def self.save_experience(user:, actor:, params:)
    actor.ability.authorize! :update, user
    user.experienced!(params[:experience])
    EventBus.broadcast('user_save_experience', user, actor, params)
  end
end
