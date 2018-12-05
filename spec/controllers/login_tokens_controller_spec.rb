require 'rails_helper'

describe LoginTokensController do
  describe 'show' do
    let(:user) { create :user, email: "test@test.com", email_verified: true }
    let(:unverified_user) { create :user, email_verified: false, email: "test@test.com" }
    let(:token) { create :login_token }

    it 'sets a session variable' do
      get :show, params: { token: token.token }
      expect(session[:pending_login_token]).to eq token.token
      expect(response).to redirect_to dashboard_path
    end

    it 'redirects to the redirect' do
      token.update(redirect: '/inbox')
      get :show, params: { token: token.token }
      expect(response).to redirect_to inbox_path
    end
  end
end
