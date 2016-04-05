require 'rails_helper'

describe StartGroupController do
  let(:user)  { create :user }

  describe '#new' do
    context 'visitor' do
      it 'renders new' do
        get :new
        expect(response).to render_template(:new)
      end
    end

    context 'logged in user with angular enabled' do
      it 'redirects to dashboard with params' do
        user.update_attribute(:angular_ui_enabled, true)
        sign_in user
        get :new
        expect(response).to redirect_to(dashboard_path(start_group: true))
      end
    end
  end
end
