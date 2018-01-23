require 'rails_helper'

describe API::OauthApplicationsController do

  let(:user) { create(:user) }
  let!(:my_app) { create(:application, owner: user) }
  let!(:other_app) { create(:application) }
  let(:access_token) { create(:access_token, resource_owner_id: user.id, application: other_app) }
  let(:app_params) {{ name: "My new app", redirect_uri: "https://loomioapp.org/callback" }}

  before do
    sign_in user
  end

  describe 'owned' do
    it 'returns apps I own' do
      get :owned
      json = JSON.parse(response.body)
      app_ids = json['oauth_applications'].map { |a| a['id'] }
      expect(app_ids).to include my_app.id
      expect(app_ids).to_not include other_app.id
    end
  end

  describe 'authorized' do
    it 'returns apps Ive authorized' do
      access_token
      get :authorized
      json = JSON.parse(response.body)
      app_ids = json['oauth_applications'].map { |a| a['id'] }
      expect(app_ids).to include other_app.id
      expect(app_ids).to_not include my_app.id
    end
  end

  describe 'show' do
    it 'shows apps I own' do
      get :show, params: { id: my_app.id }
      json = JSON.parse(response.body)
      app_ids = json['oauth_applications'].map { |a| a['id'] }
      app_secrets = json['oauth_applications'].map { |a| a['secret'] }
      expect(app_ids).to include my_app.id
      expect(app_secrets).to include my_app.secret
    end

    it 'does not show apps I do not own' do
      get :show, params: { id: other_app.id }
      expect(response.status).to eq 403
    end
  end

  describe 'update' do
    it 'updates an app I own' do
      put :update, params: { id: my_app.id, oauth_application: app_params }
      expect(response.status).to eq 200
      expect(my_app.reload.name).to eq app_params[:name]
    end

    it 'does not update an app with invalid params' do
      app_params[:redirect_uri] = ''
      put :update, params: { id: my_app.id, oauth_application: app_params }
      expect(response.status).to eq 422
      expect(my_app.reload.name).to_not eq app_params[:name]
    end

    it 'does not update an app I dont own' do
      put :update, params: { id: other_app.id, oauth_application: app_params }
      expect(response.status).to eq 403
      expect(other_app.reload.name).to_not eq app_params[:name]
    end
  end

  describe 'create' do
    it 'creates an app' do
      expect { post :create, params: { oauth_application: app_params } }.to change { OauthApplication.count }.by(1)
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      app_names = json['oauth_applications'].map { |a| a['name'] }
      expect(app_names).to include app_params[:name]
    end

    it 'does not create an invalid app' do
      app_params[:name] = ''
      expect { post :create, params: { oauth_application: app_params } }.to_not change { OauthApplication.count }
      expect(response.status).to eq 422
    end
  end

  describe 'destroy' do
    it 'destroys an app I own' do
      expect { delete :destroy, params: { id: my_app.id } }.to change { OauthApplication.count }.by(-1)
    end

    it 'does not destroy an app I dont own' do
      expect { delete :destroy, params: { id: other_app.id } }.to_not change { OauthApplication.count }
      expect(response.status).to eq 403
    end
  end

  describe 'revoke_access' do
    it 'revokes access for an app Ive approved' do
      access_token
      post :revoke_access, params: { id: other_app.id }
      expect(response.status).to eq 200
      expect(access_token.reload.revoked_at).to be_present
    end

    it 'does not revoke access for an app I havent approved' do
      post :revoke_access, params: { id: other_app.id }
      expect(response.status).to eq 403
    end
  end
end
