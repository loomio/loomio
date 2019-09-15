class Identities::Saml < Identities::Base
  include Routing
  set_identity_type :saml
  attr_accessor :response
  set_custom_fields :saml_url

  class AuthenticationRequiredError < StandardError; end

  scope :expired, -> {
    joins(:user)
      .joins("LEFT OUTER JOIN group_identities gi ON gi.identity_id = #{table_name}.id")
      .where("users.last_seen_at < ?", 1.hour.ago)
      .where("last_authenticated_at < ?", 1.day.ago)
      .where("gi.id IS NULL")
  }

  def metadata
    @metadata ||= OneLogin::RubySaml::Metadata.new.generate(saml_settings)
  end

  def auth_url
    @auth_url ||= OneLogin::RubySaml::Authrequest.new.create(saml_settings)
  end

  def fetch_user_info
    return unless saml_response&.is_valid?
    self.email = self.uid = saml_response.nameid
    self.name  = saml_response.attributes['displayName']
  end

  private

  def saml_response
    return unless response.present?
    @saml_response ||= OneLogin::RubySaml::Response.new(response, settings: saml_settings, skip_recipient_check: true)
  end

  def saml_settings
    @saml_settings ||= OneLogin::RubySaml::IdpMetadataParser.new.parse_remote(saml_url).tap do |settings|
      settings.issuer                         = saml_metadata_url
      settings.assertion_consumer_service_url = saml_oauth_url
      settings.name_identifier_format         = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'

      # # When disabled, saml validation errors will raise an exception.
      # settings.soft = true

      #SP section
      # settings.issuer                         = saml_metadata_url
      # settings.assertion_consumer_service_url = saml_oauth_callback_url
      # settings.assertion_consumer_logout_service_url = saml_unauthorize_url

      # # IdP section
      # settings.idp_entity_id                  = "https://app.onelogin.com/saml/metadata/#{onelogin_app_id}"
      # settings.idp_sso_target_url             = "https://app.onelogin.com/trust/saml2/http-redirect/sso/#{onelogin_app_id}"
      # settings.idp_slo_target_url             = "https://app.onelogin.com/trust/saml2/http-redirect/slo/#{onelogin_app_id}"
      # settings.idp_cert                       = ""

      # # Security section
      # settings.security[:authn_requests_signed] = false
      # settings.security[:logout_requests_signed] = false
      # settings.security[:logout_responses_signed] = false
      # settings.security[:metadata_signed] = false
      # settings.security[:digest_method] = XMLSecurity::Document::SHA1
      # settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA1
    end
  end

  def requires_access_token?
    false
  end
end
