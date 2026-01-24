require 'rails_helper'

describe Identities::OauthController do
  before do
    # Set required ENV variables for OAuth
    stub_const('ENV', ENV.to_hash.merge({
      'OAUTH_AUTH_URL' => 'https://oauth.provider.com/authorize',
      'OAUTH_TOKEN_URL' => 'https://oauth.provider.com/token',
      'OAUTH_PROFILE_URL' => 'https://oauth.provider.com/userinfo',
      'OAUTH_SCOPE' => 'openid profile email',
      'OAUTH_ATTR_UID' => 'sub',
      'OAUTH_ATTR_NAME' => 'name',
      'OAUTH_ATTR_EMAIL' => 'email',
      'OAUTH_APP_KEY' => 'mock_client_id',
      'OAUTH_APP_SECRET' => 'mock_client_secret'
    }))

    # Stub WebMock for OAuth HTTP requests
    stub_request(:post, 'https://oauth.provider.com/token').
      to_return(
        status: 200,
        body: { access_token: 'mock_access_token' }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    stub_request(:get, 'https://oauth.provider.com/userinfo').
      to_return(
        status: 200,
        body: {
          sub: 'oauth_user_123',
          name: 'OAuth User',
          email: 'oauth@example.com'
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )
  end

  describe 'oauth' do
    it 'redirects to the OAuth provider with correct parameters' do
      get :oauth, params: { back_to: '/some/path' }
      
      expect(session[:back_to]).to eq '/some/path'
      expect(response).to redirect_to(/https:\/\/oauth\.provider\.com\/authorize/)
      expect(response.location).to include('client_id=mock_client_id')
      expect(response.location).to include('scope=openid+profile+email')
    end

    it 'stores the referrer as back_to when no back_to param provided' do
      request.env['HTTP_REFERER'] = 'http://test.host/previous/page'
      get :oauth
      
      expect(session[:back_to]).to eq 'http://test.host/previous/page'
    end
  end

  describe 'create' do
    let(:code) { 'authorization_code_123' }

    context 'sso auth success, email login enabled, user does not exist' do
      it 'sets pending_identity to ask user to create or link account' do
        session[:back_to] = '/dashboard'
        
        expect {
          get :create, params: { code: code }
        }.to change { Identity.where(identity_type: 'oauth').count }.by(1)
         .and change { User.count }.by(0)

        identity = Identity.where(identity_type: 'oauth').last
        expect(identity.uid).to eq 'oauth_user_123'
        expect(identity.email).to eq 'oauth@example.com'
        expect(identity.user_id).to be_nil
        
        expect(session[:pending_identity_id]).to eq identity.id
        expect(controller.current_user).to be_a(LoggedOutUser)
        expect(response).to redirect_to '/dashboard'
      end
    end

    context 'sso auth success, email login disabled, user does not exist' do
      before do
        stub_const('ENV', ENV.to_hash.merge('FEATURES_DISABLE_EMAIL_LOGIN' => 'true'))
      end

      it 'creates user and signs in' do
        session[:back_to] = '/dashboard'
        
        expect {
          get :create, params: { code: code }
        }.to change { Identity.where(identity_type: 'oauth').count }.by(1)
         .and change { User.count }.by(1)

        identity = Identity.where(identity_type: 'oauth').last
        expect(identity.uid).to eq 'oauth_user_123'
        expect(identity.email).to eq 'oauth@example.com'
        expect(identity.user).to be_present
        expect(identity.user.email).to eq 'oauth@example.com'
        expect(identity.user.name).to eq 'OAuth User'
        expect(identity.user.email_verified).to eq true
        
        expect(controller.current_user).to eq identity.user
        expect(response).to redirect_to '/dashboard'
        expect(flash[:notice]).to eq I18n.t('devise.sessions.signed_in')
      end
    end

    context 'sso auth success, email verified user with same email exists' do
      let!(:existing_user) { create :user, email: 'oauth@example.com', name: 'Original Name', email_verified: true }

      it 'attaches identity to user and signs in' do
        session[:back_to] = '/dashboard'
        
        expect {
          get :create, params: { code: code }
        }.to change { Identity.where(identity_type: 'oauth').count }.by(1)
         .and change { User.count }.by(0)

        identity = Identity.where(identity_type: 'oauth').last
        expect(identity.user).to eq existing_user
        expect(existing_user.reload.identities.count).to eq 1
        
        expect(controller.current_user).to eq existing_user
        expect(response).to redirect_to '/dashboard'
        expect(flash[:notice]).to eq I18n.t('devise.sessions.signed_in')
      end

      it 'does not overwrite user name by default' do
        get :create, params: { code: code }

        existing_user.reload
        expect(existing_user.name).to eq 'Original Name'
      end
    end

    context 'sso auth success, email verified user with same email exists, sso_force_user_attrs true' do
      let!(:existing_user) { create :user, email: 'oauth@example.com', name: 'Original Name', email_verified: true }

      before do
        stub_const('ENV', ENV.to_hash.merge('LOOMIO_SSO_FORCE_USER_ATTRS' => 'true'))
      end

      it 'attaches identity to user, overwrites name, and signs in' do
        get :create, params: { code: code }

        existing_user.reload
        expect(existing_user.name).to eq 'OAuth User'
        expect(existing_user.email).to eq 'oauth@example.com'
        expect(controller.current_user).to eq existing_user
      end
    end

    context 'sso auth success, email login enabled, unverified user with same email exists' do
      let!(:existing_user) { create :user, email: 'oauth@example.com', name: 'Original Name', email_verified: false }

      it 'sets pending_identity and does not attach to unverified user' do
        session[:back_to] = '/dashboard'
        
        expect {
          get :create, params: { code: code }
        }.to change { Identity.where(identity_type: 'oauth').count }.by(1)
         .and change { User.count }.by(0)

        identity = Identity.where(identity_type: 'oauth').last
        expect(identity.user).to be_nil
        
        expect(session[:pending_identity_id]).to eq identity.id
        expect(controller.current_user).to be_a(LoggedOutUser)
        expect(response).to redirect_to '/dashboard'
      end
    end

    context 'sso auth success, email login disabled, unverified user with same email exists' do
      let!(:existing_user) { create :user, email: 'oauth@example.com', name: 'Original Name', email_verified: false }

      before do
        stub_const('ENV', ENV.to_hash.merge('FEATURES_DISABLE_EMAIL_LOGIN' => 'true'))
      end

      it 'attaches identity to user and signs in' do
        session[:back_to] = '/dashboard'
        
        expect {
          get :create, params: { code: code }
        }.to change { Identity.where(identity_type: 'oauth').count }.by(1)
         .and change { User.count }.by(0)

        identity = Identity.where(identity_type: 'oauth').last
        expect(identity.user).to eq existing_user
        
        existing_user.reload
        expect(existing_user.email_verified).to eq true
        
        expect(controller.current_user).to eq existing_user
        expect(response).to redirect_to '/dashboard'
      end
    end

    context 'sso auth success, identity already exists with same uid' do
      let!(:existing_user) { create :user, email: 'existing@example.com' }
      let!(:existing_identity) do
        Identity.create!(
          identity_type: 'oauth',
          uid: 'oauth_user_123',
          email: 'old_email@example.com',
          access_token: 'old_token',
          user: existing_user
        )
      end

      it 'updates identity and signs in existing user' do
        session[:back_to] = '/dashboard'
        
        expect {
          get :create, params: { code: code }
        }.to change { Identity.where(identity_type: 'oauth').count }.by(0)
         .and change { User.count }.by(0)

        existing_identity.reload
        expect(existing_identity.uid).to eq 'oauth_user_123'
        expect(existing_identity.email).to eq 'oauth@example.com'
        expect(existing_identity.access_token).to eq 'mock_access_token'
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

      it 'attaches identity to current user' do
        session[:back_to] = '/settings'
        
        expect {
          get :create, params: { code: code }
        }.to change { current_user.identities.count }.by(1)
         .and change { Identity.where(identity_type: 'oauth').count }.by(1)

        identity = Identity.where(identity_type: 'oauth').last
        expect(identity.user).to eq current_user
        expect(response).to redirect_to '/settings'
        expect(flash[:notice]).to eq I18n.t('devise.sessions.signed_in')
      end
    end

    context 'sso auth fail, user cancels' do
      it 'returns to dashboard with flash error' do
        session[:back_to] = '/dashboard'

        get :create, params: { error: 'access_denied' }

        expect(response).to redirect_to '/dashboard'
        expect(flash[:error]).to eq I18n.t('auth.oauth_cancelled')
      end
    end

    context 'sso auth fail, access token not returned' do
      before do
        stub_request(:post, 'https://oauth.provider.com/token').
          to_return(
            status: 400,
            body: { error: 'invalid_grant' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns 401 error' do
        get :create, params: { code: 'invalid_code' }, format: :json

        expect(response.status).to eq 401
        json = JSON.parse(response.body)
        expect(json['error']).to eq 'OAuth authorization failed'
      end
    end

    context 'sso auth fail, user profile cannot be fetched' do
      before do
        stub_request(:get, 'https://oauth.provider.com/userinfo').
          to_return(
            status: 200,
            body: { error: 'invalid_token' }.to_json,
            headers: { 'Content-Type' => 'application/json' }
          )
      end

      it 'returns 401 error' do
        get :create, params: { code: 'valid_code' }, format: :json

        expect(response.status).to eq 401
        json = JSON.parse(response.body)
        expect(json['error']).to eq 'Could not fetch user profile from OAuth provider'
      end
    end

    context 'redirects to dashboard when no back_to is set' do
      it 'uses dashboard_path as fallback' do
        get :create, params: { code: code }
        expect(response).to redirect_to dashboard_path
      end
    end
  end

  describe 'destroy' do
    let!(:user) { create :user }
    let!(:identity) do
      create :identity,
             identity_type: 'oauth',
             uid: 'oauth_user_123',
             email: 'oauth@example.com',
             access_token: 'token',
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

      expect(Identity.find_by(id: identity.id, identity_type: 'oauth')).to be_nil
      expect(response).to redirect_to 'http://test.host/settings'
    end

    it 'redirects to root when no referrer' do
      get :destroy
      expect(response).to redirect_to root_path
    end

    it 'returns error when user is not connected to oauth' do
      user.identities.destroy_all
      
      get :destroy, format: :json
      
      expect(response.status).to eq 500
      json = JSON.parse(response.body)
      expect(json['error']).to be_present
    end
  end
end
