class Identities::SamlController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  include IdentityAuthentication
  include Routing
  include SafeInternalPath

  def oauth
    session[:back_to] = safe_back_to
    auth_request = OneLogin::RubySaml::Authrequest.new
    session[:saml_request_id] = auth_request.uuid
    redirect_to auth_request.create(saml_settings)
  end

  def create
    request_id = session.delete(:saml_request_id)

    unless AppConfig.saml_allow_idp_initiated?
      return respond_with_error(401, "SAML request state missing") if request_id.blank?
    end

    saml_response = OneLogin::RubySaml::Response.new(
      params[:SAMLResponse],
      settings: saml_settings,
      matches_request_id: request_id
    )

    return respond_with_error(500, "SAML response is not valid") unless saml_response.is_valid?

    identity = begin
      IdentityService.link_or_create(
        identity_params: SamlIdentityParams.from_response(saml_response),
        current_user: current_user
      )
    rescue ActiveRecord::RecordInvalid => e
      return respond_with_error(422, e.message)
    end

    finish_identity_authentication(identity)
  end

  def metadata
    meta = OneLogin::RubySaml::Metadata.new
    render xml: meta.generate(saml_settings), content_type: "application/samlmetadata+xml"
  end

  def destroy
    disconnect_identity('saml', label: 'SAML')
  end

  private

  def safe_back_to
    safe_internal_path(params[:back_to], request.referrer)
  end

  def saml_settings
    @saml_settings ||= begin
      if AppConfig.saml_idp_metadata
        settings = OneLogin::RubySaml::IdpMetadataParser.new.parse(AppConfig.saml_idp_metadata)
      else
        settings = OneLogin::RubySaml::IdpMetadataParser.new.parse_remote(AppConfig.saml_idp_metadata_url)
      end

      settings.assertion_consumer_service_url = saml_oauth_callback_url
      settings.issuer                         = AppConfig.saml_issuer || saml_metadata_url
      settings.assertion_consumer_logout_service_url = saml_unauthorize_url
      settings.name_identifier_format         = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'

      settings.security[:digest_method] = XMLSecurity::Document::SHA256
      settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA256
      settings.security[:want_assertions_signed] = true

      settings
    end
  end
end
