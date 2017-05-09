require 'rails_helper'

describe LoginTokensController do
  describe 'show' do
    let(:token) { create :login_token }

    it 'signs in a user' do
      expect(controller).to receive(:sign_in).with(token.user)
      get :show, id: token.token
      expect(token.reload.used).to eq true
      expect(response).to redirect_to dashboard_path
    end

    it 'does not sign in a user with a used token' do
      expect(controller).to_not receive(:sign_in)
      token.update(used: true)
      get :show, id: token.token
      expect(response).to redirect_to dashboard_path
    end

    it 'does not sign in a user with an expired token' do
      expect(controller).to_not receive(:sign_in)
      token.update(created_at: 30.minutes.ago)
      get :show, id: token.token
      expect(response).to redirect_to dashboard_path
    end

    it 'does not sign in a user with an invalid token id' do
      expect(controller).to_not receive(:sign_in)
      get :show, id: "notatoken"
      expect(response.status).to eq 404
    end
  end
end
