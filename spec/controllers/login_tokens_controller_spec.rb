require 'rails_helper'

describe LoginTokensController do
  describe 'show' do
    let(:user) { create :user, email: "test@test.com", email_verified: true }
    let(:unverified_user) { create :user, email_verified: false, email: "test@test.com" }
    let(:token) { create :login_token }

    it 'signs in a user' do
      token.update(user: user)
      expect(controller).to receive(:sign_in).with(token.user)
      get :show, id: token.token
      expect(token.reload.used).to eq true
      expect(response).to redirect_to dashboard_path
    end

    it 'does not sign in a user with a used token' do
      expect(controller).to_not receive(:sign_in)
      token.update(user: user, used: true)
      get :show, id: token.token
      expect(response).to redirect_to dashboard_path
    end

    it 'does not sign in a user with an expired token' do
      expect(controller).to_not receive(:sign_in)
      token.update(user: user, created_at: 25.hours.ago)
      get :show, id: token.token
      expect(response).to redirect_to dashboard_path
    end

    it 'does not sign in a user with an invalid token id' do
      expect(controller).to_not receive(:sign_in)
      get :show, id: "notatoken"
      expect(response.status).to eq 404
    end

    it 'finds a verified user to sign in' do
      token.update(user: user)
      unverified_user
      expect(controller).to receive(:sign_in).with(user)
      get :show, id: token.token
      expect(response).to redirect_to dashboard_path
    end

    it 'signs in an unverified user' do
      token.update(user: unverified_user)
      expect(controller).to receive(:sign_in).with(unverified_user)
      get :show, id: token.token
      expect(response).to redirect_to dashboard_path
    end
  end
end
