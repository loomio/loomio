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
    if user.persisted?
      Sentry.metrics.count("user.sign_up")
    else
      Sentry.metrics.count("user.sign_up_failed", attributes: { columns: user.errors.attribute_names.join(',') })
    end

    user
  rescue ActiveRecord::RecordNotUnique
    retry
  end

  def self.verify(user: )
    return user if user.email_verified?

    user = User.verified.find_by(email: user.email) || user.tap{ |u| u.update(email_verified: true) }

    if user.email_newsletter?
      SubscribeToNewsletterWorker.perform_later(user.name, user.email)
    end

    user
  end

  def self.deactivate(user:, actor:)
    actor.ability.authorize! :deactivate, user
    Sentry.metrics.count("user.deactivate", attributes: { self_initiated: actor.id == user.id })
    DeactivateUserWorker.perform_later(user.id, actor.id)
  end

  def self.redact(user:, actor:)
    actor.ability.authorize! :redact, user
    Sentry.metrics.count("user.redact", attributes: { self_initiated: actor.id == user.id })
    RedactUserWorker.perform_later(user.id, actor.id)
  end

  def self.reactivate(user_id)
    user = User.find(user_id)
    deactivated_at = user.deactivated_at
    Membership.where(user_id: user.id, revoked_at: deactivated_at).update_all(revoked_at: nil, revoker_id: nil)
    group_ids = Membership.where(user_id: user.id).pluck(:group_id)
    Group.where(id: group_ids).map(&:update_memberships_count)
    Group.update_org_members_count_for_group_ids(group_ids)
    user.update(deactivated_at: nil)
    ReindexAuthorWorker.perform_later(user.id)
  end

  def self.set_volume(user:, actor:, params:)
    actor.ability.authorize! :update, user
    membership_attributes = {}
    user_attributes = {}

    if params[:volume_email].present?
      email = params[:volume_email].to_s
      unless User.volume_email_defaults.key?(email)
        user.errors.add :volume_email_default, I18n.t(:"activerecord.errors.messages.invalid")
        raise ActiveRecord::RecordInvalid, user
      end
      membership_attributes[:volume_email] = Membership.volume_emails.fetch(email)
      user_attributes[:volume_email_default] = email
    end

    if params[:volume_push].present?
      push = params[:volume_push].to_s
      unless User.volume_push_defaults.key?(push)
        user.errors.add :volume_push_default, I18n.t(:"activerecord.errors.messages.invalid")
        raise ActiveRecord::RecordInvalid, user
      end
      membership_attributes[:volume_push] = Membership.volume_pushes.fetch(push)
      user_attributes[:volume_push_default] = push
    end

    raise ActionController::ParameterMissing, :volume if user_attributes.empty?

    user.update!(user_attributes)
    if params[:apply_to_all]
      user.memberships.update_all(membership_attributes)
      user.topic_readers.update_all(membership_attributes)
    end
    EventBus.broadcast('user_set_volume', user, actor, params)
  end

  def self.update(user:, actor:, params:)
    actor.ability.authorize! :update, user
    
    remove_externally_managed_profile_fields(params) if disable_edit_user_profile?
    
    user.assign_attributes_and_files(params)
    unless user.valid?
      Sentry.metrics.count("user.update_failed", attributes: { columns: user.errors.attribute_names.join(',') })
      return user
    end
    password_changed = user.password_digest_changed?
    user.save!
    if password_changed
      rotate_credentials_after_password_change(user)
      Sentry.metrics.count("user.password_changed")
    end
    EventBus.broadcast('user_update', user, actor, params)
    ReindexAuthorWorker.perform_later(user.id) if user.name_previously_changed?
    user
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
    user.mobile_devices.active.find_each(&:revoke!)
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
