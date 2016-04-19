require 'rails_helper'

describe Users::EmailPreferencesController do
  describe "edit" do
    let(:user) { create :user, angular_ui_enabled: true }

    it 'renders the beta interface for betea user when an unsubscribe token is present' do
      user.update(angular_ui_enabled: false)
      get :edit, unsubscribe_token: user.unsubscribe_token
      expect(response).to render_template(:edit)
    end

    it 'renders the beta interface for beta user when signed in' do
      user.update(angular_ui_enabled: false)
      sign_in user
      get :edit
      expect(response).to render_template(:edit)
    end

    it 'renders the angular interface when logged in and unsubscribe_token is present' do
      get :edit, unsubscribe_token: user.unsubscribe_token
      expect(response).to render_template(:angular)
    end

    it 'renders the angular interface when signed in' do
      sign_in user
      get :edit
      expect(response).to render_template(:angular)
    end

    it 'redirects to sign in page when logged out' do
      get :edit
      expect(response).to redirect_to new_user_session_path
    end
  end

end
