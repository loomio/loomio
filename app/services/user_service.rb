class UserService
  def self.verify(user: )
    # if !user.is_verified and verified_sign_in_method
    return user if user.email_verified?
      # user = UserService.verify(user)
    # check if already verfied user with
    if verified_user = User.verified.find_by(email: user.email)
      # merge records and return verified person
      merge(source: user, destination: verified_user)
      verified_user
    else
      user.update(email_verified: true)
      user
    end
  end

  def self.remind(model:, actor:, user:)
    actor.ability.authorize! :remind, model

    EventBus.broadcast 'user_remind', model, actor, user
    Events::UserReminded.publish!(model, actor, user)
  end

  def self.merge(source:, destination:)
    poll_ids = from.participated_poll_ids & to.participated_poll_ids
    Stance.where(participant: from).update_all(participant: to)
    Stance.where(participant: to, poll_id: poll_ids).update_all(latest: false)

    Poll.where(id: poll_ids).each do |poll|
      poll.stances.where(participant: to).order(created_at: :desc).first.update_attribute(:latest, true)
    end
  end

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
