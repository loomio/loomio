class Identities::SamlController < Identities::BaseController
  before_action :store_saml_url, only: :oauth
  after_action :clear_saml_url, only: :create

  def metadata
    render xml: identity.metadata, content_type: "application/samlmetadata+xml"
  end

  private

  def oauth_url
    identity.auth_url
  end

  def identity_params
    { saml_url: session[:saml_metadata_url], response: params[:SAMLResponse] }
  end

  def store_saml_url
    session[:saml_metadata_url] = params.fetch(:saml_url, ENV['SAML_IDP_METADATA_URL'])
  end

  def clear_saml_url
    session.delete(:saml_metadata_url)
  end
end
