class Identities::Saml < Identities::Base
  include Routing
  set_identity_type :saml
  attr_accessor :response

  def initialize(response: "")
    super.tap do
      self.response          = OneLogin::RubySaml::Response.new(response, skip_recipient_check: true)
      self.response.settings = OneLogin::RubySaml::IdpMetadataParser.new.parse_remote(ENV['SAML_APP_SECRET'])
      self.response.settings.assertion_consumer_service_url = saml_oauth_url
      self.response.settings.issuer                         = root_url
      self.response.settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
    end
  end

  def fetch_user_info
    self.uid = self.email = self.response.nameid if self.response.is_valid?
  end

  def requires_access_token?
    false
  end
end
