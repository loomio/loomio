class Identities::SamlController < Identities::BaseController
  def metadata
    meta = OneLogin::RubySaml::Metadata.new
    render :xml => meta.generate(sp_settings), :content_type => "application/samlmetadata+xml"
  end

  private

  def oauth_url
    OneLogin::RubySaml::Authrequest.new.create(Identities::Saml.new.settings)
  end

  def identity_params
    { response: params[:SAMLResponse] }
  end

  def sp_settings
    # this is just for testing purposes.
    # should retrieve SAML-settings based on subdomain, IP-address, NameID or similar
    settings = OneLogin::RubySaml::Settings.new

    # When disabled, saml validation errors will raise an exception.
    settings.soft = true

    #SP section
    settings.issuer                         = saml_metadata_url
    settings.assertion_consumer_service_url = saml_oauth_callback_url
    settings.assertion_consumer_logout_service_url = saml_unauthorize_url

    # onelogin_app_id = "<onelogin-app-id>"
    #
    # # IdP section
    # settings.idp_entity_id                  = "https://app.onelogin.com/saml/metadata/#{onelogin_app_id}"
    # settings.idp_sso_target_url             = "https://app.onelogin.com/trust/saml2/http-redirect/sso/#{onelogin_app_id}"
    # settings.idp_slo_target_url             = "https://app.onelogin.com/trust/saml2/http-redirect/slo/#{onelogin_app_id}"
    # settings.idp_cert                       = ""


    # or settings.idp_cert_fingerprint           = ""
    #    settings.idp_cert_fingerprint_algorithm = XMLSecurity::Document::SHA1

    settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

    # Security section
    settings.security[:authn_requests_signed] = false
    settings.security[:logout_requests_signed] = false
    settings.security[:logout_responses_signed] = false
    settings.security[:metadata_signed] = false
    settings.security[:digest_method] = XMLSecurity::Document::SHA1
    settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA1

    settings
  end
end
