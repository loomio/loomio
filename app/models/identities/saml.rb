class Identities::Saml < Identities::Base
  include Routing
  set_identity_type :saml
  attr_accessor :response

  def initialize(response: "")
    super.tap do
      self.response = OneLogin::RubySaml::Response.new(response, skip_recipient_check: true)
    end
  end

  def fetch_user_info
    self.response.settings = settings
    self.uid = self.email = self.response.nameid if self.response.is_valid?
  end

  def settings
    OneLogin::RubySaml::Settings.new.tap do |settings|
      settings.assertion_consumer_service_url = saml_oauth_url
      settings.issuer                         = root_url
      settings.idp_sso_target_url             = ENV['SAML_APP_KEY'] # NB this is a IDP url in the case of SAML
      settings.idp_cert_fingerprint           = ENV['SAML_APP_SECRET']
      settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
    end
  end

  def requires_access_token?
    false
  end
end
