class UserService
  class EmailTakenError < StandardError
  end

  def self.create(params:)
    if User.where(email_verified: true, email: params[:email]).exists?
      raise UserService::EmailTakenError.new(email: params[:email])
    end

    user = User.where(email_verified: false, email: params[:email]).first_or_create
    user.attributes = params.slice(:name, :email, :legal_accepted, :email_newsletter)
    user.require_valid_signup = true
    user.save

    user
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def self.verify(user: )
    return user if user.email_verified?

    user = User.verified.find_by(email: user.email) || user.tap{ |u| u.update(email_verified: true) }

    if user.email_newsletter?
      GenericWorker.perform_later('NewsletterService', 'subscribe', user.name, user.email)
    end

    user
  end

  def self.deactivate(user:, actor:)
    actor.ability.authorize! :deactivate, user
    DeactivateUserWorker.perform_later(user.id, actor.id)
  end

  def self.redact(user:, actor:)
    actor.ability.authorize! :redact, user
    RedactUserWorker.perform_later(user.id, actor.id)
  end

  def self.reactivate(user_id)
    user = User.find(user_id)
    deactivated_at = user.deactivated_at
    Membership.where(user_id: user.id, revoked_at: deactivated_at).update_all(revoked_at: nil, revoker_id: nil)
    group_ids = Membership.where(user_id: user.id).pluck(:group_id)
    Group.where(id: group_ids).map(&:update_memberships_count)
    user.update(deactivated_at: nil)
    GenericWorker.perform_later('SearchService', 'reindex_by_author_id', user.id)
  end

  def self.set_volume(user:, actor:, params:)
    actor.ability.authorize! :update, user
    user.update!(default_membership_volume: params[:volume])
    if params[:apply_to_all]
      user.memberships.update_all(volume: Membership.volumes[params[:volume]])
      user.topic_readers.update_all(volume: Membership.volumes[params[:volume]])
    end
    EventBus.broadcast('user_set_volume', user, actor, params)
  end

  def self.update(user:, actor:, params:)
    actor.ability.authorize! :update, user
    
    remove_externally_managed_profile_fields(params) if disable_edit_user_profile?
    
    user.assign_attributes_and_files(params)
    return false unless user.valid?
    password_changed = user.password_digest_changed?
    user.save!
    rotate_credentials_after_password_change(user) if password_changed
    EventBus.broadcast('user_update', user, actor, params)
    GenericWorker.perform_later('SearchService', 'reindex_by_author_id', user.id) if user.name_previously_changed?
  end

  def self.disable_edit_user_profile?
    ENV['LOOMIO_SSO_FORCE_USER_ATTRS'].present? ||
      ActiveModel::Type::Boolean.new.cast(ENV['LOOMIO_DISABLE_EDIT_USER_PROFILE'])
  end

  def self.remove_externally_managed_profile_fields(params)
    [:name, :email, :username, :avatar_kind, :uploaded_avatar].each do |field|
      params.delete(field)
    end
  end

  def self.rotate_credentials_after_password_change(user)
    user.update_columns(
      api_key: User.generate_unique_secure_token,
      email_api_key: User.generate_unique_secure_token,
      secret_token: User.generate_unique_secure_token,
      unsubscribe_token: User.generate_unique_secure_token
    )
    user.login_tokens.unused.destroy_all
    sign_out_other_sessions(user)
  end

  def self.sign_out_other_sessions(user)
    sessions = user.sessions
    sessions = sessions.where.not(id: Current.session.id) if Current.session
    sessions.destroy_all
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
