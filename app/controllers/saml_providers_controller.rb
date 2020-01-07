class SamlProvidersController < ApplicationController
  def auth
    session[:back_to] = params[:back_to] || request.referrer
    session[:saml_provider_id] = params[:id]
    redirect_to idp_auth_url
  end

  def metadata
    render :xml => OneLogin::RubySaml::Metadata.new.generate(sp_settings(params_saml_provider)), :content_type => "application/samlmetadata+xml"
  end

  def invitation_created
    render plain: "Almost there! Please check your #{params[:email]} inbox for a link to join #{params_saml_provider.group.name}."
  end

  def callback
    saml_provider = session_saml_provider
    saml_response = OneLogin::RubySaml::Response.new(params[:SAMLResponse], settings: sp_settings(saml_provider))

    session.delete(:saml_provider_id)

    if saml_response.success?
      email = saml_response.nameid
      group = saml_provider.group

      if current_user.is_logged_in?
        group.add_member!(current_user)
        signed_in_success_redirect
      elsif user_is_existing_member?(email, group)
        sign_in User.active.find_by!(email: email)
        signed_in_success_redirect
      else
        inviter = GroupInviter.new(group: group, emails: [email], inviter: group.creator).invite!
        Events::AnnouncementCreated.publish! group, group.creator, inviter.invited_memberships, :group_announced
        redirect_to invitation_created_saml_provider_url(saml_provider.id, email: email)
      end
    else
      authorize_failure  # This method shows an error message
    end
  end

  private

  def signed_in_success_redirect
    redirect_to session.delete(:back_to) || dashboard_path
  end

  def user_is_existing_member?(email, group)
    Membership.active.joins(:user).where('users.email' => email, :group_id => group.id).exists?
  end

  def params_saml_provider
    SamlProvider.find_by!(id: params[:id])
  end

  def session_saml_provider
    SamlProvider.find_by!(id: session[:saml_provider_id])
  end

  def idp_auth_url
    OneLogin::RubySaml::Authrequest.new.create(idp_settings)
  end

  def idp_settings
    settings = OneLogin::RubySaml::IdpMetadataParser.new.parse_remote(params_saml_provider.idp_metadata_url)
    settings.assertion_consumer_service_url = callback_saml_providers_url
    settings.issuer                         = metadata_saml_provider_url(params_saml_provider)
    settings.name_identifier_format         = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'
    settings
  end

  def fetch_user_info
    return unless self.response.is_valid?
    logger.info self.response
    self.email = self.uid = self.response.nameid
    self.name = self.response.attributes['displayName']
  end

  def find_group_member_by_email(email)
    saml_provider.group.accepted_members.find_by(email: email)
  end

  def associate_identity
    # when can we trust a saml provider to allow us to sign in a user?
    # when it is a new user to create
    # when the user already belongs to the group
    # otherwise we send an email invitation for the user to accept


    if user = current_user.presence || find_group_member_by_email(email)
      user.associate_with_identity(identity)
      sign_in(user)
      flash[:notice] = t(:'devise.sessions.signed_in')
    else
      # create a user, add them to the group
      # if user already exists but is not a group member, they need to verify their email address
    end
  end

  def sp_settings(saml_provider)
    settings = OneLogin::RubySaml::Settings.new

    # When disabled, saml validation errors will raise an exception.
    settings.soft = true

    #SP section
    settings.issuer                         = metadata_saml_provider_url(saml_provider)
    settings.assertion_consumer_service_url = callback_saml_providers_url
    settings.assertion_consumer_logout_service_url = logout_saml_provider_url(saml_provider)

    settings.name_identifier_format         = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

    settings.security[:authn_requests_signed] = false
    settings.security[:logout_requests_signed] = false
    settings.security[:logout_responses_signed] = false
    settings.security[:metadata_signed] = false
    settings.security[:digest_method] = XMLSecurity::Document::SHA1
    settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA1
    settings
  end
end
