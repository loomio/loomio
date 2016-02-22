require 'rails_helper'

describe OauthApplicationsController do
  let(:user) { create(:user) }
  let(:my_app) { create(:application, owner: user) }
  let(:other_app) { create(:application) }
  let(:application_params) { { name: 'my app', redirect_uri: 'https://loomio.org' } }

  describe 'index' do
    it 'lists only applications I have created' do
      sign_in user
      get :index
      expect(assigns(:applications)).to include my_app
      expect(assigns(:applications)).to_not include other_app
    end

    it 'redirects to sign in page if I am logged out' do
      get :index
      expect(response).to redirect_to new_user_session_path
    end
  end

  describe 'show' do
    it 'displays an application that I have created' do
      sign_in user
      get :show, id: my_app.id
      expect(assigns(:application)).to eq my_app
    end

    it 'does not display applications I have not created' do
      sign_in user
      get :show, id: other_app.id
      expect(response.status).to eq 403
    end

    it 'redirects to sign in page if I am logged out' do
      get :show, id: my_app.id
      expect(response).to redirect_to new_user_session_path
    end
  end

  describe 'create' do
    it 'creates a new application' do
      sign_in user
      expect { post :create, doorkeeper_application: application_params }.to change { OauthApplication.count }.by(1)
      application = OauthApplication.last
      expect(application.owner).to eq user
      expect(application.name).to eq application_params[:name]
    end
  end

  describe 'update' do
    it 'can update an existing application' do
      sign_in user
      my_app
      post :update, id: my_app.id, doorkeeper_application: application_params
      expect(my_app.reload.name).to eq application_params[:name]
      expect(my_app.redirect_uri).to eq application_params[:redirect_uri]
    end
  end
end
