class SamlIdentityParams
  FULL_NAME_ATTRIBUTES = %w[
    displayName
    name
    cn
    fullName
    http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name
  ].freeze

  EMAIL_ATTRIBUTES = %w[
    email
    mail
    emailAddress
    userPrincipalName
    http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress
    urn:oid:0.9.2342.19200300.100.1.3
  ].freeze

  GIVEN_NAME_ATTRIBUTES = %w[
    givenName
    firstName
    given_name
    http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname
  ].freeze

  FAMILY_NAME_ATTRIBUTES = %w[
    sn
    surname
    familyName
    family_name
    lastName
    http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname
  ].freeze

  def self.from_response(response)
    new(response).to_h
  end

  def initialize(response)
    @name_id = response.nameid.to_s.strip
    @attributes = normalize_attributes(response.attributes)
  end

  def to_h
    {
      identity_type: 'saml',
      uid: @name_id,
      email: email,
      name: name,
      access_token: nil
    }
  end

  private

  def normalize_attributes(attributes)
    attributes.each_with_object({}) do |(key, value), result|
      result[key.to_s.downcase] = Array(value).first.to_s.squish.presence
    end
  end

  def email
    configured_email_attribute = AppConfig.saml_attribute_email
    return attribute([ configured_email_attribute ]) if configured_email_attribute.present?
    return @name_id if EmailValidator::EMAIL_REGEXP.match?(@name_id)

    attribute(EMAIL_ATTRIBUTES)
  end

  def name
    configured_name_attribute = AppConfig.saml_attribute_name
    return attribute([ configured_name_attribute ]) if configured_name_attribute.present?

    configured_given_name = AppConfig.saml_attribute_given_name
    configured_family_name = AppConfig.saml_attribute_family_name
    if configured_given_name.present? || configured_family_name.present?
      return joined_name([ configured_given_name ].compact, [ configured_family_name ].compact)
    end

    attribute(FULL_NAME_ATTRIBUTES) || joined_name(GIVEN_NAME_ATTRIBUTES, FAMILY_NAME_ATTRIBUTES)
  end

  def joined_name(given_names, family_names)
    [ attribute(given_names), attribute(family_names) ].compact.join(' ').presence
  end

  def attribute(names)
    names.filter_map { |name| @attributes[name.downcase] }.first
  end
end
