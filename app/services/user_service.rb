class UserService
  def self.create(user:, params:)
    user.attributes = params.slice(:name, :email, :recaptcha, :legal_accepted, :email_newsletter)
    user.require_valid_signup = true
    user.require_recaptcha = true
    user.update_attachments!
    user.save.tap do
      EventBus.broadcast 'user_create', user
    end
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

  # UserService#deactivate
  # When someone no longer wants to be on the system, this is the way to remove them.
  #
  # It nulls any personally identifying user record columns
  # it deletes any login_tokens, identities, etc
  # it deactivates membership records
  # it preserves authored discussions, comments, polls, stances, reactions, files
  #
  # it should, ideally, also send an undo link to the email address on file,
  # which is the only way for someone to claim this user account again
  def self.deactivate(user:)
    user.ability.authorize! :deactivate, user
    DeactivateUserWorker.perform_async(user.id)
  end

  # UserService#destroy
  # Only intended to be used in a case where a script has created trash records and you
  # want to make it as if it never happened. We almost never want to destroy a user.
  # it will destroy
  # - all groups they created
  # - all discussions they authored
  # - all polls they authored
  # - all comments they created
  # - all stances they created
  # - all memberships they have
  # # all discussion_readers they have
  # you get the point.
  def self.destroy(user:)
    DestroyUserWorker.perform_async(user.id)
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
    user.update_attachments!
    user.save
    EventBus.broadcast('user_update', user, actor, params)
  end

  def self.save_experience(user:, actor:, params:)
    actor.ability.authorize! :update, user
    user.experienced!(params[:experience], !params[:remove_experience])
    EventBus.broadcast('user_save_experience', user, actor, params)
  end
end
