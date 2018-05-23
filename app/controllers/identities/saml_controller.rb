class Identities::SamlController < Identities::BaseController
  private

  def oauth_url
    OneLogin::RubySaml::Authrequest.new.create(Identities::Saml.new.settings)
  end

  def identity_params
    { response: params[:SAMLResponse] }
  end
end
