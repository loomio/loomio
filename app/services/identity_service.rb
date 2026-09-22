class IdentityService
  # Links or creates an SSO identity and associated user account
  #
  # When a user is already signed in:
  # - Creates a pending identity to prevent accidental account linking
  # - Expects the user to intentionally link via identity_form.vue
  #
  # When user is not signed in:
  # - Searches for existing user by email (verified or unverified)
  # - Links identity to existing user or creates new user
  # - Sets email_verified: true
  #
  # @param identity_params [Hash] SSO identity data: uid, identity_type, email, name, access_token
  # @param current_user [User, nil] Currently logged-in user (if any)
  #
  # @return [Identity] The linked or created identity
  def self.link_or_create(identity_params:, current_user:)
    identity = find_or_create_identity(identity_params: identity_params, current_user: current_user)
    refresh_identity(identity, identity_params: identity_params)

    return identity unless identity.user

    sync_user_profile(identity)
    sync_user_avatar(identity)

    identity
  end

  def self.update_user_profile_on_login?
    AppConfig.sso_update_user_profile_on_login?
  end

  def self.find_or_create_identity(identity_params:, current_user:)
    identity_type = identity_params[:identity_type]
    uid = identity_params[:uid]
    identity = find_identity(identity_type: identity_type, uid: uid)
    return identity if identity

    # create_or_find_by! rolls back a user created in the block when another
    # login wins the identity insertion race.
    Identity.create_or_find_by!(identity_type: identity_type, uid: uid) do |new_identity|
      new_identity.assign_attributes(identity_params)
      assign_user_for_new_identity(new_identity, current_user: current_user)
    end
  end
  private_class_method :find_or_create_identity

  def self.assign_user_for_new_identity(identity, current_user:)
    # A signed-in user must intentionally link a newly encountered identity.
    return if current_user.present?

    # The configured SSO provider is trusted as the authority on email
    # ownership. A matching provider email therefore links the existing user.
    identity.user = User.find_by(email: identity.email)
    if identity.user
      initialize_user_name(identity.user, fallback: identity.name)
      identity.user.email_verified = true
      identity.user.save! if identity.user.changed?
    else
      identity.user = User.new(name: identity.name, email: identity.email, email_verified: true)
      Sentry.set_context(
        'identity_params',
        identity.attributes.slice('identity_type', 'uid', 'email', 'name')
      )
      identity.user.save!
    end
  end
  private_class_method :assign_user_for_new_identity

  def self.refresh_identity(identity, identity_params:)
    identity.assign_attributes(identity_params)
    Identity.transaction do
      if identity.user
        # Invitations create nameless placeholder users. Initialize their name
        # before sign-in even when ongoing profile synchronization is disabled.
        initialize_user_name(identity.user, fallback: identity.name)
        identity.user.save! if identity.user.changed?
      end
      identity.save! if identity.changed?
    end
  end
  private_class_method :refresh_identity

  def self.sync_user_profile(identity)
    return unless update_user_profile_on_login?

    identity.user.update(name: identity.name, email: identity.email)
  end
  private_class_method :sync_user_profile

  def self.sync_user_avatar(identity)
    return unless identity.logo.present?
    return if identity.user.avatar_kind == 'uploaded' && !update_user_profile_on_login?

    identity.assign_logo!
  end
  private_class_method :sync_user_avatar

  def self.find_identity(identity_type:, uid:)
    Identity.with_user.find_by(identity_type: identity_type, uid: uid) ||
      Identity.find_by(identity_type: identity_type, uid: uid)
  end
  private_class_method :find_identity

  def self.initialize_user_name(user, fallback:)
    return if user.name.present?

    user.name = fallback
  end
  private_class_method :initialize_user_name
end
