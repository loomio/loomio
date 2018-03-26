class Identities::Saml < Identities::Base
  include Identities::WithClient
  set_identity_type :saml

  def initialize(response:)
    @identity = OneLogin::RubySaml::Response.new(response).tap { |i| i.settings = settings }
  end

  def valid?
    @identity.is_valid?
  end

  def fetch_user_info
    @identity.settings = self.class.settings
  end

  def self.settings
    host = ENV['CANONICAL_HOST'] || 'localhost:3000'
    OneLogin::RubySaml::Settings.new.tap do |settings|
      settings.assertion_consumer_service_url = [host, 'saml', 'consume'].join('/')
      settings.issuer                         = [host, 'saml', 'consume'].join('/')
      settings.idp_sso_target_url             = "https://app.onelogin.com/saml/signon/#{ENV['SAML_APP_KEY']}"
      settings.idp_cert_fingerprint           = ENV['SAML_APP_SECRET']
      settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
      settings.attribute_consuming_service.configure do
        service_name "Loomio"
        service_index 5
        add_attribute name: "Loomio", name_format: "Normal?", friendly_name: "Loomio"
      end
    end
  end
end
