class SamlProvidersController < ApplicationController
  def auth
    session[:back_to] = params[:back_to] || request.referrer
    redirect_to idp_auth_url
  end

  def metadata
    render :xml => OneLogin::RubySaml::Metadata.new.generate(sp_settings), :content_type => "application/samlmetadata+xml"
  end

  def callback
    saml_response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], settings: sp_settings)
    p saml_response.methods - Object.methods

    if saml_response.success?
      if current_user.is_logged_in?
        if current_user.is_member_of?(samp_provider.group))
          membership.update(session_expires_at: saml_response.session_expires_at)
        end
      else
        if User.where(email: saml_response.nameid).exists?
          # send user a sign in email
        else
          # create user and sign them in
        end
      end


       # authorize_success, log the user
      # if current_user
      # else existing user with this email?
      # else new user with this email
      #
      # membership for this provider's group

      redirect to session.delete(:back_to) || dashboard_path
    else
      authorize_failure  # This method shows an error message
    end
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
    settings.assertion_consumer_service_url = callback_saml_provider_url(saml_provider)
    settings.issuer                         = metadata_saml_provider_url(saml_provider)
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
    # when can we trust a saml provider to allow us to sign in a user?
    # when it is a new user to create
    # when the user already belongs to the group
    # otherwise we send an email invitation for the user to accept


    if user = current_user.presence || find_group_member_by_email(email)
      user.associate_with_identity(identity)
      sign_in(user)
      flash[:notice] = t(:'devise.sessions.signed_in')
    else
      # create a user, add them to the group
      # if user already exists but is not a group member, they need to verify their email address
    end
  end

  def sp_settings
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
    settings
  end
end
