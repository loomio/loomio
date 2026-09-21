class Identities::SamlController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :create
  include Routing
  
  def oauth
    session[:back_to] = safe_back_to
    auth_request = OneLogin::RubySaml::Authrequest.new
    session[:saml_request_id] = auth_request.uuid
    redirect_to auth_request.create(saml_settings)
  end

  def create
    request_id = session.delete(:saml_request_id)

    unless ENV['SAML_ALLOW_IDP_INITIATED'].present?
      return respond_with_error(401, "SAML request state missing") if request_id.blank?
    end

    saml_response = OneLogin::RubySaml::Response.new(
      params[:SAMLResponse],
      settings: saml_settings,
      matches_request_id: request_id
    )

    return respond_with_error(500, "SAML response is not valid") unless saml_response.is_valid?

    nameid = saml_response.nameid.to_s.strip
    attributes = saml_attributes(saml_response.attributes)

    identity_params = {
      identity_type: 'saml',
      uid: nameid,
      email: saml_email(attributes, fallback: nameid),
      name: saml_name(attributes),
      access_token: nil
    }

    identity = begin
      IdentityService.link_or_create(
        identity_params: identity_params,
        current_user: current_user
      )
    rescue ActiveRecord::RecordInvalid => e
      return respond_with_error(422, e.message)
    end

    # Handle pending identity flow (user is switching accounts)
    if !identity.user
      back_to = session[:back_to]
      sign_out
      session[:pending_identity_id] = identity.id
      flash[:notice] = t('auth.switching_accounts')
      return redirect_to session.delete(:return_to_after_authenticating) || back_to || dashboard_path
    end

    if identity.user.account_completion_required?
      stage_account_completion(identity.user, name_managed: identity.name.present?)
      session[:pending_user_id] = identity.user.id
      return redirect_to authentication_return_path(fallback: dashboard_path)
    end

    # Handle successful login
    sign_in(identity.user)
    flash[:notice] = t('auth_form.signed_in')

    redirect_to authentication_return_path(fallback: dashboard_path)
  end
  
  def metadata
    meta = OneLogin::RubySaml::Metadata.new
    render xml: meta.generate(saml_settings), content_type: "application/samlmetadata+xml"
  end

  def destroy
    if i = current_user.identities.find_by(identity_type: 'saml')
      i.destroy
      redirect_to request.referrer || root_path
    else
      respond_with_error 500, "Not connected to SAML!"
    end
  end

  private

  SAML_FULL_NAME_ATTRIBUTES = %w[
    displayName
    name
    cn
    fullName
    http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name
  ].freeze

  SAML_EMAIL_ATTRIBUTES = %w[
    email
    mail
    emailAddress
    userPrincipalName
    http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress
    urn:oid:0.9.2342.19200300.100.1.3
  ].freeze

  SAML_GIVEN_NAME_ATTRIBUTES = %w[
    givenName
    firstName
    given_name
    http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname
  ].freeze

  SAML_FAMILY_NAME_ATTRIBUTES = %w[
    sn
    surname
    familyName
    family_name
    lastName
    http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname
  ].freeze

  def saml_attributes(attributes)
    attributes.each_with_object({}) do |(key, value), result|
      result[key.to_s.downcase] = Array(value).first.to_s.squish.presence
    end
  end

  def saml_email(attributes, fallback:)
    if ENV['SAML_ATTR_EMAIL'].present?
      saml_attribute(attributes, [ ENV['SAML_ATTR_EMAIL'] ])
    elsif EmailValidator::EMAIL_REGEXP.match?(fallback)
      fallback
    else
      saml_attribute(attributes, SAML_EMAIL_ATTRIBUTES)
    end
  end

  def saml_name(attributes)
    if ENV['SAML_ATTR_NAME'].present?
      return saml_attribute(attributes, [ ENV['SAML_ATTR_NAME'] ])
    end

    if ENV['SAML_ATTR_GIVEN_NAME'].present? || ENV['SAML_ATTR_FAMILY_NAME'].present?
      return [
        saml_attribute(attributes, [ ENV['SAML_ATTR_GIVEN_NAME'] ].compact),
        saml_attribute(attributes, [ ENV['SAML_ATTR_FAMILY_NAME'] ].compact)
      ].compact.join(' ').presence
    end

    saml_attribute(attributes, SAML_FULL_NAME_ATTRIBUTES) ||
      [
        saml_attribute(attributes, SAML_GIVEN_NAME_ATTRIBUTES),
        saml_attribute(attributes, SAML_FAMILY_NAME_ATTRIBUTES)
      ].compact.join(' ').presence
  end

  def saml_attribute(attributes, names)
    names.filter_map { |name| attributes[name.downcase] }.first
  end

  def safe_back_to
    path = (params[:back_to] || request.referrer).to_s
    path if path.start_with?('/') && !path.start_with?('//', '/\\')
  end

  def saml_settings
    @saml_settings ||= begin
      if ENV['SAML_IDP_METADATA']
        settings = OneLogin::RubySaml::IdpMetadataParser.new.parse(ENV['SAML_IDP_METADATA'])
      else
        settings = OneLogin::RubySaml::IdpMetadataParser.new.parse_remote(ENV.fetch('SAML_IDP_METADATA_URL'))
      end
      
      settings.assertion_consumer_service_url = saml_oauth_callback_url
      settings.issuer                         = ENV.fetch('SAML_ISSUER', saml_metadata_url)
      settings.assertion_consumer_logout_service_url = saml_unauthorize_url
      settings.name_identifier_format         = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
      
      settings.security[:digest_method] = XMLSecurity::Document::SHA256
      settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA256
      settings.security[:want_assertions_signed] = true

      settings
    end
  end
end
