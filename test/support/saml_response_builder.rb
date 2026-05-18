require 'openssl'
require 'base64'
require 'securerandom'
require 'time'

# Builds signed SAML responses for testing.
# Usage:
#   builder = SamlResponseBuilder.new
#   base64_response = builder.build(email: "pass@example.com", name: "Test User")
#   post saml_oauth_callback_path, params: { SAMLResponse: base64_response }
#
# Emails starting with "fail@" will generate an unsigned/invalid response.
module SamlResponseBuilder
  CERT_PATH = File.expand_path('../saml_test_cert.pem', __FILE__)
  KEY_PATH  = File.expand_path('../saml_test_key.pem', __FILE__)

  def self.cert
    @cert ||= OpenSSL::X509::Certificate.new(File.read(CERT_PATH))
  end

  def self.key
    @key ||= OpenSSL::PKey::RSA.new(File.read(KEY_PATH))
  end

  def self.cert_fingerprint
    OpenSSL::Digest::SHA256.hexdigest(cert.to_der).scan(/../).join(':')
  end

  # Returns a Base64-encoded SAMLResponse suitable for posting to the ACS endpoint.
  def self.build(email:, name: "Test User", audience: "http://localhost:3000/saml/metadata", recipient: "http://localhost:3000/saml/oauth")
    now = Time.now.utc
    not_on_or_after = now + 300
    response_id = "_#{SecureRandom.uuid}"
    assertion_id = "_#{SecureRandom.uuid}"

    assertion_xml = <<~XML
      <saml:Assertion xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="#{assertion_id}" IssueInstant="#{now.iso8601}" Version="2.0">
        <saml:Issuer>test-saml-idp</saml:Issuer>
        <saml:Subject>
          <saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress">#{email}</saml:NameID>
          <saml:SubjectConfirmation Method="urn:oasis:names:tc:SAML:2.0:cm:bearer">
            <saml:SubjectConfirmationData NotOnOrAfter="#{not_on_or_after.iso8601}" Recipient="#{recipient}"/>
          </saml:SubjectConfirmation>
        </saml:Subject>
        <saml:Conditions NotBefore="#{(now - 60).iso8601}" NotOnOrAfter="#{not_on_or_after.iso8601}">
          <saml:AudienceRestriction>
            <saml:Audience>#{audience}</saml:Audience>
          </saml:AudienceRestriction>
        </saml:Conditions>
        <saml:AuthnStatement AuthnInstant="#{now.iso8601}" SessionIndex="#{assertion_id}">
          <saml:AuthnContext>
            <saml:AuthnContextClassRef>urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport</saml:AuthnContextClassRef>
          </saml:AuthnContext>
        </saml:AuthnStatement>
        <saml:AttributeStatement>
          <saml:Attribute Name="displayName">
            <saml:AttributeValue>#{name}</saml:AttributeValue>
          </saml:Attribute>
        </saml:AttributeStatement>
      </saml:Assertion>
    XML

    signed_assertion = sign_xml(assertion_xml.strip, assertion_id)

    response_xml = <<~XML
      <samlp:Response xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="#{response_id}" Version="2.0" IssueInstant="#{now.iso8601}" Destination="#{recipient}" InResponseTo="_request">
        <saml:Issuer>test-saml-idp</saml:Issuer>
        <samlp:Status>
          <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/>
        </samlp:Status>
        #{signed_assertion}
      </samlp:Response>
    XML

    Base64.strict_encode64(response_xml.strip)
  end

  # Builds an invalid (unsigned) SAML response for testing rejection
  def self.build_unsigned(email:, name: "Test User", recipient: "http://localhost:3000/saml/oauth")
    now = Time.now.utc
    response_id = "_#{SecureRandom.uuid}"
    assertion_id = "_#{SecureRandom.uuid}"

    response_xml = <<~XML
      <samlp:Response xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion" ID="#{response_id}" Version="2.0" IssueInstant="#{now.iso8601}" Destination="#{recipient}">
        <saml:Issuer>test-saml-idp</saml:Issuer>
        <samlp:Status>
          <samlp:StatusCode Value="urn:oasis:names:tc:SAML:2.0:status:Success"/>
        </samlp:Status>
        <saml:Assertion ID="#{assertion_id}" IssueInstant="#{now.iso8601}" Version="2.0">
          <saml:Issuer>test-saml-idp</saml:Issuer>
          <saml:Subject>
            <saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress">#{email}</saml:NameID>
          </saml:Subject>
        </saml:Assertion>
      </samlp:Response>
    XML

    Base64.strict_encode64(response_xml.strip)
  end

  # Returns IdP metadata XML that points to the test cert
  def self.idp_metadata
    <<~XML
      <EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata" entityID="test-saml-idp">
        <IDPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
          <KeyDescriptor use="signing">
            <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
              <ds:X509Data>
                <ds:X509Certificate>#{Base64.strict_encode64(cert.to_der)}</ds:X509Certificate>
              </ds:X509Data>
            </ds:KeyInfo>
          </KeyDescriptor>
          <NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</NameIDFormat>
          <SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="http://localhost:7000/saml/sso"/>
        </IDPSSODescriptor>
      </EntityDescriptor>
    XML
  end

  private

  def self.sign_xml(xml, reference_id)
    doc = Nokogiri::XML(xml)
    canon = doc.root.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
    digest = Base64.strict_encode64(OpenSSL::Digest::SHA256.digest(canon))

    signed_info_xml = <<~XML
      <ds:SignedInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#" xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion">
        <ds:CanonicalizationMethod Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
        <ds:SignatureMethod Algorithm="http://www.w3.org/2001/04/xmldsig-more#rsa-sha256"/>
        <ds:Reference URI="##{reference_id}">
          <ds:Transforms>
            <ds:Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"/>
            <ds:Transform Algorithm="http://www.w3.org/2001/10/xml-exc-c14n#"/>
          </ds:Transforms>
          <ds:DigestMethod Algorithm="http://www.w3.org/2001/04/xmlenc#sha256"/>
          <ds:DigestValue>#{digest}</ds:DigestValue>
        </ds:Reference>
      </ds:SignedInfo>
    XML

    signed_info_canon = Nokogiri::XML(signed_info_xml).root.canonicalize(Nokogiri::XML::XML_C14N_EXCLUSIVE_1_0)
    signature_value = Base64.strict_encode64(key.sign(OpenSSL::Digest::SHA256.new, signed_info_canon))

    signature_xml = <<~XML
      <ds:Signature xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
        #{signed_info_xml.strip}
        <ds:SignatureValue>#{signature_value}</ds:SignatureValue>
        <ds:KeyInfo>
          <ds:X509Data>
            <ds:X509Certificate>#{Base64.strict_encode64(cert.to_der)}</ds:X509Certificate>
          </ds:X509Data>
        </ds:KeyInfo>
      </ds:Signature>
    XML

    # Insert signature after Issuer element
    doc = Nokogiri::XML(xml)
    issuer = doc.root.at_xpath('saml:Issuer', 'saml' => 'urn:oasis:names:tc:SAML:2.0:assertion')
    issuer.add_next_sibling(signature_xml.strip)
    doc.root.to_xml
  end
end
