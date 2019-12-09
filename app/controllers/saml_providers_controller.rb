class SamlProvidersController < ApplicationController
  def auth
    session[:back_to] = params[:back_to] || request.referrer
    redirect_to idp_auth_url
  end

  def metadata
    meta = OneLogin::RubySaml::Metadata.new
    render :xml => meta.generate(sp_settings), :content_type => "application/samlmetadata+xml"
  end

  def callback
    # if current_user
    # else existing user with this email?
    # else new user with this email
    #
    # membership for this provider's group

    membership.authenicated_at = Time.now
    redirect to session.delete(:back_to) || dashboard_path
  end

  private
  def idp_auth_url
    OneLogin::RubySaml::Authrequest.new.create(Identities::Saml.new.settings)
  end


  def saml_provider
    @saml_provider ||= SamlProvicer.find_by!(id: params[:id])
  end

  def settings
    @settings ||= begin
      settings = OneLogin::RubySaml::IdpMetadataParser.new.parse_remote(saml_provider.idp_metadata_url)
      settings.assertion_consumer_service_url = saml_provider_oauth_url(saml_provider)
      settings.issuer                         = saml_provider_metadata_url(saml_provider)
      settings.name_identifier_format         = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
      settings
    end
  end

  def fetch_user_info
    return unless self.response.is_valid?
    logger.info self.response
    self.email = self.uid = self.response.nameid
    self.name = self.response.attributes['displayName']
  end

  def client
    @client ||= "Clients::#{controller_name.classify}".constantize.instance
  end

  def redirect_uri
    send :"#{controller_name}_authorize_url"
  end

  def identity
    @identity ||= identity_class.new.tap do |i|
      i.response          = OneLogin::RubySaml::Response.new(params[:SAMLResponse], skip_recipient_check: true)
      i.response.settings = i.settings
      complete_identity(i)
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
