class Identities::Saml < Identities::Base
  include Routing
  set_identity_type :saml
  attr_accessor :response

  def settings
    @settings ||= begin
      if ENV['SAML_IDP_METADATA']
        settings = OneLogin::RubySaml::IdpMetadataParser.new.parse(ENV['SAML_IDP_METADATA'])
      else
        settings = OneLogin::RubySaml::IdpMetadataParser.new.parse_remote(ENV['SAML_IDP_METADATA_URL'])
      end
      settings.assertion_consumer_service_url = saml_oauth_url
      settings.issuer                         = ENV.fetch('SAML_ISSUER', saml_metadata_url)
      settings.name_identifier_format         = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
      settings
    end
  end

  def fetch_user_info
    return unless self.response.is_valid?
    self.email = self.uid = self.response.nameid
    self.name = self.response.attributes['displayName']
  end

  def requires_access_token?
    false
  end
end
