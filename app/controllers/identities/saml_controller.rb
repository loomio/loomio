# This controller expects you to use the URLs /saml/init and /saml/consume in your OneLogin application.
class Identities::SamlController < Identities::BaseController
  private

  def oauth_url
    OneLogin::RubySaml::Authrequest.new.create(Identities::Saml.settings)
  end

  def identity_params
    { response: params[:SAMLResponse] }
  end
end
