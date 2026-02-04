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

    # Find or create identity by uid (the immutable SSO identifier)
    identity = Identity.find_by(identity_type: identity_type, uid: uid)

    if identity
      # Existing identity found - update its attributes (email/name may have changed in SSO)
      identity.update(identity_params)
    else
      # New identity - need to create it and link to a user
      identity = Identity.new(identity_params)

      # SECURITY: If user is already signed in, don't auto-link new identities
      # This prevents accidental linking of SSO accounts. Users can intentionally
      # link identities via the identity_form.vue UI if they choose to.
      if current_user.present?
        identity.save
        return identity
      end

      # Try to find existing user by email (verified or unverified)
      # This enables transparent account linking for both new and invited users
      identity.user = User.find_by(email: email)

      if identity.user.nil?
        # No existing user found - create new verified user
        identity.user = User.new(identity_params.slice(:name, :email).merge(email_verified: true))
        identity.user.save!
      else
        # User found (verified or unverified) - mark email as verified
        identity.user.update(email_verified: true) unless identity.user.email_verified
      end

      identity.save
    end

    # Sync user attributes from SSO provider if configured
    if ENV['LOOMIO_SSO_FORCE_USER_ATTRS'] && identity.user
      identity.user.update(name: identity.name, email: identity.email)
    end

    identity
  end
end
