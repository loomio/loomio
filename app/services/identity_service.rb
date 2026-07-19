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
    identity_type = identity_params[:identity_type]
    uid = identity_params[:uid]
    email = identity_params[:email]

    # Find existing identity by uid, preferring one already linked to a user.
    # This matters because legacy code created orphan duplicates on every login.
    identity = find_identity(identity_type: identity_type, uid: uid)

    # create_or_find_by! handles another login creating the same identity after
    # the lookup above. Its transaction also rolls back any user created by the
    # block when the identity insert loses that race.
    identity ||= Identity.create_or_find_by!(identity_type: identity_type, uid: uid) do |new_identity|
      new_identity.assign_attributes(identity_params)

      # SECURITY: If user is already signed in, don't auto-link new identities.
      # Users can intentionally link the pending identity via identity_form.vue.
      next if current_user.present?

      # The configured SSO provider is trusted as the authority on email ownership.
      new_identity.user = User.find_by(email: email)

      if new_identity.user.nil?
        new_identity.user = User.new(identity_params.slice(:name, :email).merge(email_verified: true))
        Sentry.set_context('identity_params', identity_params.slice(:identity_type, :uid, :email, :name))
        new_identity.user.save!
      else
        new_identity.user.update(email_verified: true) unless new_identity.user.email_verified?
      end
    end

    # Existing identities may have changed email, name, token, or profile image.
    identity.assign_attributes(identity_params)
    identity.save! if identity.changed?

    return identity unless identity.user

    # Sync user attributes from SSO provider if configured
    if update_user_profile_on_login? && identity.user
      identity.user.update(name: identity.name, email: identity.email)
    end

    # Apply the SSO provider's profile picture if the user hasn't uploaded their own
    if identity.user && identity.logo.present? && identity.user.avatar_kind != 'uploaded'
      identity.assign_logo!
    end

    identity
  end

  def self.update_user_profile_on_login?
    ENV['LOOMIO_SSO_FORCE_USER_ATTRS'].present? ||
      ActiveModel::Type::Boolean.new.cast(ENV['LOOMIO_SSO_UPDATE_USER_PROFILE_ON_LOGIN'])
  end

  def self.find_identity(identity_type:, uid:)
    Identity.with_user.find_by(identity_type: identity_type, uid: uid) ||
      Identity.find_by(identity_type: identity_type, uid: uid)
  end
  private_class_method :find_identity
end
