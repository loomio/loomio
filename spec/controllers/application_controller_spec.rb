require 'rails_helper'

describe ApplicationController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe "GET 'boot_angular_ui'" do
    context 'angular_ui_enabled' do
      it 'does not show a welcome modal for current angular users' do
        get :boot_angular_ui
        expect(assigns(:appConfig)[:showWelcomeModal]).to eq true
      end
    end

    context 'angular_ui not enabled' do
      it 'sets angular ui enabled to true' do
        user.update(angular_ui_enabled: false)
        get :boot_angular_ui
        expect(user.reload.angular_ui_enabled).to eq true
        expect(assigns(:appConfig)[:showWelcomeModal]).to eq true

        get :boot_angular_ui
        expect(assigns(:appConfig)[:showWelcomeModal]).to eq false
      end
    end
  end
end
