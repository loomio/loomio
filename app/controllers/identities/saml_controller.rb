class Identities::SamlController < ApplicationController
  skip_before_action :verify_authenticity_token
  include Routing
  
  def oauth
    session[:back_to] = params[:back_to] || request.referrer
    auth_request = OneLogin::RubySaml::Authrequest.new
    redirect_to auth_request.create(saml_settings)
  end

  def create
    saml_response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], skip_recipient_check: true)
    saml_response.settings = saml_settings

    return respond_with_error(500, "SAML response is not valid") unless saml_response.is_valid?

    identity_params = {
      identity_type: 'saml',
      uid: saml_response.nameid,
      email: saml_response.nameid,
      name: saml_response.attributes['displayName'],
      access_token: nil
    }

    identity = IdentityService.link_or_create(
      identity_params: identity_params,
      current_user: current_user
    )

    # Handle pending identity flow (user is switching accounts)
    if !identity.user
      back_to = session[:back_to]
      sign_out
      session[:pending_identity_id] = identity.id
      flash[:notice] = t(:'auth.switching_accounts')
      return redirect_to back_to || dashboard_path
    end

    # Handle successful login
    sign_in(identity.user)
    flash[:notice] = t(:'devise.sessions.signed_in')

    redirect_to session.delete(:back_to) || dashboard_path
  end
  
  def metadata
    meta = OneLogin::RubySaml::Metadata.new
    render xml: meta.generate(saml_settings), content_type: "application/samlmetadata+xml"
  end

  def destroy
    if i = current_user.identities.find_by(identity_type: 'saml')
      i.destroy
      redirect_to request.referrer || root_path
    else
      respond_with_error 500, "Not connected to SAML!"
    end
  end

  private

  def saml_settings
    @saml_settings ||= begin
      if ENV['SAML_IDP_METADATA']
        settings = OneLogin::RubySaml::IdpMetadataParser.new.parse(ENV['SAML_IDP_METADATA'])
      else
        settings = OneLogin::RubySaml::IdpMetadataParser.new.parse_remote(ENV.fetch('SAML_IDP_METADATA_URL'))
      end
      
      settings.assertion_consumer_service_url = saml_oauth_callback_url
      settings.issuer                         = ENV.fetch('SAML_ISSUER', saml_metadata_url)
      settings.assertion_consumer_logout_service_url = saml_unauthorize_url
      settings.name_identifier_format         = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
      
      # Security settings
      settings.soft = true
      settings.security[:authn_requests_signed] = false
      settings.security[:logout_requests_signed] = false
      settings.security[:logout_responses_signed] = false
      settings.security[:metadata_signed] = false
      settings.security[:digest_method] = XMLSecurity::Document::SHA1
      settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA1
      
      settings
    end
  end
end
