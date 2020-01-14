class UserService
  def self.create(user:, params:)
    user.attributes = params.slice(:name, :email, :recaptcha, :legal_accepted)
    user.require_valid_signup = true
    user.require_recaptcha = true
    user.save.tap do
      EventBus.broadcast 'user_create', user
    end
  end

  def self.destroy(user:)
    DestroyUserWorker.perform_async(user.id)
  end

  def self.verify(user: )
    return user if user.email_verified?
    User.verified.find_by(email: user.email) || user.tap{ |u| u.update(email_verified: true) }
  end

  def self.remind(model:, actor:, user:)
    actor.ability.authorize! :remind, model

    EventBus.broadcast 'user_remind', model, actor, user
    Events::UserReminded.publish!(model, actor, user)
  end

  def self.move_records(from: , to: )
    poll_ids = from.participated_poll_ids & to.participated_poll_ids
    Stance.where(participant_id: from.id).update_all(participant_id: to.id)
    Stance.where(participant_id: to.id, poll_id: poll_ids).update_all(latest: false)

    Poll.where(id: poll_ids).each do |poll|
      poll.stances.where(participant_id: to.id).order(created_at: :desc).first.update_attribute(:latest, true)
    end
  end

  def self.delete_many_spam(name_fragment)
    return unless name_fragment.to_s.length > 6
    User.where('name like ?', "%#{name_fragment}%").order('id asc').limit(2000).each { |user| delete_spam(user) }
  end

  def self.delete_spam(user)
    # destroyed (cascade delete)
    raise "no deletey admin plezse" if user.is_admin?

    Group.where(creator_id: user.id).destroy_all
    Poll.where(author_id: user.id).destroy_all
    Discussion.where(author_id: user.id).destroy_all

    # deleted (fast delete)
    Event.where(user_id: user.id).delete_all
    Notification.where(actor_id: user.id).delete_all

    user.destroy
    EventBus.broadcast('user_delete_spam', user)
  end

  def self.deactivate(user:, actor:, params:)
    actor.ability.authorize! :deactivate, user
    user.deactivate!
    EventBus.broadcast('user_deactivate', user, actor, params)
  end

  def self.reactivate(user:, actor:)
    actor.ability.authorize! :reactivate, user
    EventBus.broadcast('user_reactivate', user, actor)
    Events::UserReactivated.publish!(user)
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
    HasRichText.assign_attributes_and_update_files(user, params)
    user.save
    EventBus.broadcast('user_update', user, actor, params)
  end

  def self.save_experience(user:, actor:, params:)
    actor.ability.authorize! :update, user
    user.experienced!(params[:experience], !params[:remove_experience])
    EventBus.broadcast('user_save_experience', user, actor, params)
  end
end
