class SamlProvidersController < ApplicationController
  def auth
    session[:back_to] = params[:back_to] || request.referrer
    redirect_to idp_auth_url
  end

  def metadata
    render :xml => generate_sp_metadata, :content_type => "application/samlmetadata+xml"
  end

  def callback
    saml_response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], skip_recipient_check: true)

    # if current_user
    # else existing user with this email?
    # else new user with this email
    #
    # membership for this provider's group

    membership.authenicated_at = Time.now
    redirect to session.delete(:back_to) || dashboard_path
  end

  private
  def saml_provider
    @saml_provider ||= SamlProvider.find_by!(id: params[:id])
  end

  def idp_auth_url
    OneLogin::RubySaml::Authrequest.new.create(idp_settings)
  end

  def idp_settings
    settings = OneLogin::RubySaml::IdpMetadataParser.new.parse_remote(saml_provider.idp_metadata_url)
    settings.assertion_consumer_service_url = saml_provider_oauth_url(saml_provider)
    settings.issuer                         = saml_provider_metadata_url(saml_provider)
    settings.name_identifier_format         = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
    settings
  end

  def fetch_user_info
    return unless self.response.is_valid?
    logger.info self.response
    self.email = self.uid = self.response.nameid
    self.name = self.response.attributes['displayName']
  end

  def find_group_member_by_email(email)
    saml_provider.group.accepted_members.find_by(email: email)
  end

  def associate_identity
    # the saml provider says we have an authenticated user
    # what's safe?
    # logged in/logged out and existing email or new email

    # logged out
      # user account with this email does not exist
        # -> create user account, mark email as verified, and sign them in
        
      # user account with this email exists
        # the user already belongs to the saml_provider group
          # -> log them into the account
        # the user does not belong to the saml_provider group
          # -> add the user to the group, but send a login email to ensure they have not setup a fake idp

    # logged in
      # current_user email matches the saml_provider email
        # -> add them to the group, updated authenticated_at and sign them in
      # current_user email does not match saml_provider email
        # should we be looking up identities with this provider to find the user?

    if user = current_user.presence || find_group_member_by_email(email)
      user.associate_with_identity(identity)
      sign_in(user)
      flash[:notice] = t(:'devise.sessions.signed_in')
    else
      # create a user, add them to the group
      # if user already exists but is not a group member, they need to verify their email address
    end
  end

  def generate_sp_metadata
    settings = OneLogin::RubySaml::Settings.new

    # When disabled, saml validation errors will raise an exception.
    settings.soft = true

    #SP section
    settings.issuer                         = metadata_saml_provider_url(saml_provider)
    settings.assertion_consumer_service_url = callback_saml_provider_url(saml_provider)
    settings.assertion_consumer_logout_service_url = logout_saml_provider_url(saml_provider)

    settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

    settings.security[:authn_requests_signed] = false
    settings.security[:logout_requests_signed] = false
    settings.security[:logout_responses_signed] = false
    settings.security[:metadata_signed] = false
    settings.security[:digest_method] = XMLSecurity::Document::SHA1
    settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA1

    OneLogin::RubySaml::Metadata.new.generate(settings)
  end

end
