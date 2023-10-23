class UserService
  class EmailTakenError < StandardError
  end

  def self.create(params:)
    if User.where(email_verified: true, email: params[:email]).exists?
      raise UserService::EmailTakenError.new(email: params[:email])
    end

    user = User.where(email_verified: false, email: params[:email]).first_or_create
    user.attributes = params.slice(:name, :email, :recaptcha, :legal_accepted, :email_newsletter)
    user.require_valid_signup = true
    user.require_recaptcha = true
    user.save
    user
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def self.verify(user: )
    return user if user.email_verified?
    User.verified.find_by(email: user.email) || user.tap{ |u| u.update(email_verified: true) }
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
  def self.deactivate(user:, actor:)
    actor.ability.authorize! :deactivate, user
    DeactivateUserWorker.perform_async(user.id, actor.id)
  end

  # this is for user accounts deactivated with the older method
  def self.reactivate(user_id)
    user = User.find(user_id)
    deactivated_at = user.deactivated_at
    Membership.where(user_id: user.id, revoked_at: deactivated_at).update_all(revoked_at: nil)
    group_ids = Membership.where(user_id: user.id).pluck(:group_id)
    Group.where(id: group_ids).map(&:update_memberships_count)
    user.update(deactivated_at: nil)
    GenericWorker.perform_async('SearchService', 'reindex_by_author_id', user.id)
  end

  # # UserService#destroy
  # # Only intended to be used in a case where a script has created trash records and you
  # # want to make it as if it never happened. We almost never want to destroy a user.
  # # it will destroy
  # # - all groups they created
  # # - all discussions they authored
  # # - all polls they authored
  # # - all comments they created
  # # - all stances they created
  # # - all memberships they have
  # # # all discussion_readers they have
  # # you get the point.
  # def self.destroy(user:)
  #   DestroyUserWorker.perform_async(user.id)
  # end

  def self.set_volume(user:, actor:, params:)
    actor.ability.authorize! :update, user
    user.update!(default_membership_volume: params[:volume])
    if params[:apply_to_all]
      user.memberships.update_all(volume: Membership.volumes[params[:volume]])
      user.discussion_readers.update_all(volume: Membership.volumes[params[:volume]])
      user.stances.update_all(volume: Membership.volumes[params[:volume]])
    end
    EventBus.broadcast('user_set_volume', user, actor, params)
  end

  def self.update(user:, actor:, params:)
    actor.ability.authorize! :update, user
    user.assign_attributes_and_files(params)
    return false unless user.valid?
    user.save!
    EventBus.broadcast('user_update', user, actor, params)
    GenericWorker.perform_async('SearchService', 'reindex_by_author_id', user.id) if user.name_previously_changed?
  end

  def self.save_experience(user:, actor:, params:)
    actor.ability.authorize! :update, user
    name = params[:experience]
    value = if params.has_key?(:remove_experience)
      nil
    else
      params.fetch(:value, true)
    end
    user.experiences[name] = value
    user.save!
    EventBus.broadcast('user_save_experience', user, actor, params)
  end
end
