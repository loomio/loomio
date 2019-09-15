require 'rails_helper'

describe Identities::SamlController do
  let(:user) { create :user }
  let(:saml_url) { "https://example.onelogin.com/key" }

  it 'uses a saml url if one is provided' do
    get :oauth, params: { saml_url: saml_url }
    expect(response).to redirect_to /test.onelogin.com/
  end

  it 'uses an ENV value if no saml url is provided' do
    ENV['SAML_IDP_METADATA_URL'] = saml_url
    get :oauth
    expect(response).to redirect_to /test.onelogin.com/
    ENV['SAML_IDP_METADATA_URL'] = nil
  end

  it 'renders 404 if no saml url is provided and no ENV is set' do
    get :oauth
    expect(response.status).to eq 404
  end
end
