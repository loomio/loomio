require 'rails_helper'

describe Identities::SamlController do
  before do
    # Set required ENV variables for SAML
    stub_const('ENV', ENV.to_hash.merge({
      'SAML_IDP_METADATA_URL' => 'https://saml.provider.com/metadata',
      'SAML_ISSUER' => 'https://loomio.test/saml/metadata'
    }))

    # Mock SAML metadata parsing
    saml_settings = instance_double(OneLogin::RubySaml::Settings)
    allow(saml_settings).to receive(:assertion_consumer_service_url=)
    allow(saml_settings).to receive(:issuer=)
    allow(saml_settings).to receive(:assertion_consumer_logout_service_url=)
    allow(saml_settings).to receive(:name_identifier_format=)
    allow(saml_settings).to receive(:soft=)
    allow(saml_settings).to receive(:security).and_return({})
    
    parser = instance_double(OneLogin::RubySaml::IdpMetadataParser)
    allow(OneLogin::RubySaml::IdpMetadataParser).to receive(:new).and_return(parser)
    allow(parser).to receive(:parse_remote).and_return(saml_settings)
  end

  describe 'oauth' do
    it 'redirects to SAML IdP with auth request' do
      auth_request = instance_double(OneLogin::RubySaml::Authrequest)
      allow(OneLogin::RubySaml::Authrequest).to receive(:new).and_return(auth_request)
      allow(auth_request).to receive(:create).and_return('https://saml.provider.com/login?SAMLRequest=...')

      get :oauth, params: { back_to: '/some/path' }
      
      expect(session[:back_to]).to eq '/some/path'
      expect(response).to redirect_to('https://saml.provider.com/login?SAMLRequest=...')
    end

    it 'stores the referrer as back_to when no back_to param provided' do
      auth_request = instance_double(OneLogin::RubySaml::Authrequest)
      allow(OneLogin::RubySaml::Authrequest).to receive(:new).and_return(auth_request)
      allow(auth_request).to receive(:create).and_return('https://saml.provider.com/login?SAMLRequest=...')
      
      request.env['HTTP_REFERER'] = 'http://test.host/previous/page'
      get :oauth
      
      expect(session[:back_to]).to eq 'http://test.host/previous/page'
    end
  end

  describe 'create' do
    let(:saml_response_xml) { 'base64_encoded_saml_response' }
    let(:saml_response) { instance_double(OneLogin::RubySaml::Response) }

    before do
      allow(OneLogin::RubySaml::Response).to receive(:new).and_return(saml_response)
      allow(saml_response).to receive(:settings=)
      allow(saml_response).to receive(:nameid).and_return('user@example.com')
      allow(saml_response).to receive(:attributes).and_return({ 'displayName' => 'SAML User' })
      allow(saml_response).to receive(:is_valid?).and_return(true)
    end

    context 'sso auth success, user does not exist' do
      it 'creates user and signs in' do
        session[:back_to] = '/dashboard'

        expect {
          post :create, params: { SAMLResponse: saml_response_xml }
        }.to change { Identity.where(identity_type: 'saml').count }.by(1)
         .and change { User.count }.by(1)

        identity = Identity.where(identity_type: 'saml').last
        expect(identity.uid).to eq 'user@example.com'
        expect(identity.email).to eq 'user@example.com'
        expect(identity.name).to eq 'SAML User'
        expect(identity.user).to be_present
        expect(identity.user.email).to eq 'user@example.com'
        expect(identity.user.name).to eq 'SAML User'
        expect(identity.user.email_verified).to eq true

        expect(controller.current_user).to eq identity.user
        expect(response).to redirect_to '/dashboard'
        expect(flash[:notice]).to eq I18n.t('devise.sessions.signed_in')
      end
    end

    context 'sso auth success, user with same email exists' do
      let!(:existing_user) { create :user, email: 'user@example.com', name: 'Original Name', email_verified: true }

      it 'attaches identity to user and signs in' do
        session[:back_to] = '/dashboard'

        expect {
          post :create, params: { SAMLResponse: saml_response_xml }
        }.to change { Identity.where(identity_type: 'saml').count }.by(1)
         .and change { User.count }.by(0)

        identity = Identity.where(identity_type: 'saml').last
        expect(identity.user).to eq existing_user
        expect(existing_user.reload.identities.count).to eq 1

        expect(controller.current_user).to eq existing_user
        expect(response).to redirect_to '/dashboard'
        expect(flash[:notice]).to eq I18n.t('devise.sessions.signed_in')
      end

      it 'does not overwrite user name by default' do
        post :create, params: { SAMLResponse: saml_response_xml }

        existing_user.reload
        expect(existing_user.name).to eq 'Original Name'
      end
    end

    context 'sso auth success, email verified user with same email exists, sso_force_user_attrs true' do
      let!(:existing_user) { create :user, email: 'user@example.com', name: 'Original Name', email_verified: true }

      before do
        stub_const('ENV', ENV.to_hash.merge('LOOMIO_SSO_FORCE_USER_ATTRS' => 'true'))
      end

      it 'attaches identity to user, overwrites name, and signs in' do
        post :create, params: { SAMLResponse: saml_response_xml }

        existing_user.reload
        expect(existing_user.name).to eq 'SAML User'
        expect(existing_user.email).to eq 'user@example.com'
        expect(controller.current_user).to eq existing_user
      end
    end

    context 'sso auth success, unverified user with same email exists (from invitation)' do
      let!(:existing_user) { create :user, email: 'user@example.com', name: 'Original Name', email_verified: false }

      it 'attaches identity to user, verifies email, and signs in' do
        session[:back_to] = '/dashboard'

        expect {
          post :create, params: { SAMLResponse: saml_response_xml }
        }.to change { Identity.where(identity_type: 'saml').count }.by(1)
         .and change { User.count }.by(0)

        identity = Identity.where(identity_type: 'saml').last
        expect(identity.user).to eq existing_user

        existing_user.reload
        expect(existing_user.email_verified).to eq true

        expect(controller.current_user).to eq existing_user
        expect(response).to redirect_to '/dashboard'
        expect(flash[:notice]).to eq I18n.t('devise.sessions.signed_in')
      end
    end

    context 'sso auth success, user exists but identity is missing (regression test)' do
      let!(:existing_user) { create :user, email: 'user@example.com', name: 'Original Name', email_verified: true }

      it 'links existing user to new identity without attempting to create duplicate user' do
        session[:back_to] = '/dashboard'

        # This should NOT raise ActiveRecord::RecordInvalid error
        expect {
          post :create, params: { SAMLResponse: saml_response_xml }
        }.to change { Identity.where(identity_type: 'saml').count }.by(1)
         .and change { User.count }.by(0)

        identity = Identity.where(identity_type: 'saml').last
        expect(identity.user).to eq existing_user
        expect(identity.uid).to eq 'user@example.com'
        expect(identity.email).to eq 'user@example.com'

        expect(controller.current_user).to eq existing_user
        expect(response).to redirect_to '/dashboard'
        expect(flash[:notice]).to eq I18n.t('devise.sessions.signed_in')
      end
    end

    context 'sso auth success, user exists with different email (uid as source of truth)' do
      let!(:existing_user) { create :user, email: 'old@example.com', name: 'Original Name', email_verified: true }
      let!(:existing_identity) do
        Identity.create!(
          identity_type: 'saml',
          uid: 'user@example.com',
          email: 'old@example.com',
          name: 'Original Name',
          access_token: nil,
          user: existing_user
        )
      end

      before do
        stub_const('ENV', ENV.to_hash.merge('LOOMIO_SSO_FORCE_USER_ATTRS' => 'true'))
      end

      it 'updates identity with new email from SSO and syncs to user' do
        session[:back_to] = '/dashboard'

        expect {
          post :create, params: { SAMLResponse: saml_response_xml }
        }.to change { Identity.where(identity_type: 'saml').count }.by(0)
         .and change { User.count }.by(0)

        existing_identity.reload
        expect(existing_identity.email).to eq 'user@example.com'
        expect(existing_identity.name).to eq 'SAML User'
        expect(existing_identity.user).to eq existing_user
        
        # User attributes should be synced from SSO
        existing_user.reload
        expect(existing_user.email).to eq 'user@example.com'
        expect(existing_user.name).to eq 'SAML User'
        
        expect(controller.current_user).to eq existing_user
        expect(response).to redirect_to '/dashboard'
      end
    end

    context 'sso auth success, identity already exists with same uid' do
      let!(:existing_user) { create :user, email: 'existing@example.com' }
      let!(:existing_identity) do
        Identity.create!(
          identity_type: 'saml',
          uid: 'user@example.com',
          email: 'old@example.com',
          access_token: nil,
          user: existing_user
        )
      end

      it 'updates identity and signs in existing user' do
        session[:back_to] = '/dashboard'
        
        expect {
          post :create, params: { SAMLResponse: saml_response_xml }
        }.to change { Identity.where(identity_type: 'saml').count }.by(0)
         .and change { User.count }.by(0)

        existing_identity.reload
        expect(existing_identity.uid).to eq 'user@example.com'
        expect(existing_identity.email).to eq 'user@example.com'
        expect(existing_identity.name).to eq 'SAML User'
        expect(existing_identity.user).to eq existing_user
        
        expect(controller.current_user).to eq existing_user
        expect(response).to redirect_to '/dashboard'
        expect(flash[:notice]).to eq I18n.t('devise.sessions.signed_in')
      end
    end

    context 'sso auth success, user already signed in' do
      let!(:current_user) { create :user }

      before do
        sign_in current_user
      end

      it 'creates pending identity instead of auto-linking' do
        session[:back_to] = '/settings'

        expect {
          post :create, params: { SAMLResponse: saml_response_xml }
        }.to change { Identity.where(identity_type: 'saml').count }.by(1)
         .and change { current_user.identities.count }.by(0)

        identity = Identity.where(identity_type: 'saml').last
        expect(identity.user_id).to be_nil  # Pending identity, not linked
        expect(identity.email).to eq 'user@example.com'

        expect(session[:pending_identity_id]).to eq identity.id
        expect(response).to redirect_to '/settings'
        expect(flash[:notice]).to eq I18n.t('auth.switching_accounts')
      end
    end

    context 'sso auth fail, invalid SAML response' do
      before do
        allow(saml_response).to receive(:is_valid?).and_return(false)
      end

      it 'returns error' do
        post :create, params: { SAMLResponse: saml_response_xml }, format: :json
        
        expect(response.status).to eq 500
        json = JSON.parse(response.body)
        expect(json['error']).to eq 'SAML response is not valid'
      end
    end

    context 'redirects to dashboard when no back_to is set' do
      it 'uses dashboard_path as fallback' do
        post :create, params: { SAMLResponse: saml_response_xml }
        expect(response).to redirect_to dashboard_path
      end
    end
  end

  describe 'metadata' do
    it 'returns SAML metadata XML' do
      metadata = instance_double(OneLogin::RubySaml::Metadata)
      allow(OneLogin::RubySaml::Metadata).to receive(:new).and_return(metadata)
      allow(metadata).to receive(:generate).and_return('<xml>metadata</xml>')

      get :metadata
      
      expect(response.content_type).to include 'application/samlmetadata+xml'
      expect(response.body).to eq '<xml>metadata</xml>'
    end
  end

  describe 'destroy' do
    let!(:user) { create :user }
    let!(:identity) do
      create :identity,
             identity_type: 'saml',
             uid: 'saml_user_123',
             email: 'saml@example.com',
             access_token: nil,
             user: user
    end

    before do
      sign_in user
    end

    it 'destroys the identity connection' do
      request.env['HTTP_REFERER'] = 'http://test.host/settings'
      
      expect {
        get :destroy
      }.to change { user.identities.count }.by(-1)

      expect(Identity.find_by(id: identity.id, identity_type: 'saml')).to be_nil
      expect(response).to redirect_to 'http://test.host/settings'
    end

    it 'redirects to root when no referrer' do
      get :destroy
      expect(response).to redirect_to root_path
    end

    it 'returns error when user is not connected to saml' do
      user.identities.destroy_all
      
      get :destroy, format: :json
      
      expect(response.status).to eq 500
      json = JSON.parse(response.body)
      expect(json['error']).to be_present
    end
  end
end
