class Identities::Saml < Identities::Base
  include Routing
  set_identity_type :saml
  attr_accessor :response

  def initialize(response: "")
    super.tap do
      self.response          = OneLogin::RubySaml::Response.new(response, skip_recipient_check: true)
      self.response.settings = settings
    end
  end

  def settings
    @settings ||= begin
      settings = OneLogin::RubySaml::IdpMetadataParser.new.parse_remote(ENV['SAML_APP_SECRET'])
      settings.assertion_consumer_service_url = saml_oauth_url
      settings.issuer                         = root_url
      settings.name_identifier_format         = ENV['SLACK_APP_EMAIL_FIELD']
      settings
    end
  end

  def fetch_user_info
    return unless self.response.is_valid?
    self.email = self.uid = self.response.nameid
    self.name  = self.response.attributes[ENV['SAML_APP_NAME_FIELD']]
  end

  def requires_access_token?
    false
  end
end
