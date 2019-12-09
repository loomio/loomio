require 'rails_helper'

describe SamlProvidersController do
  let(:group) { create :formal_group }
  let(:saml_provider) { SamlProvider.create(group: group, idp_metadata_url: 'https://samlprovider.com/metadata') }

  it 'redirects users to the auth page' do
    get :oauth, {saml_provider_id: saml_provider.id}
    expect response.code.to eq 200
  end
end
