require 'rails_helper'

describe API::B3::UsersController do
  let(:user) { create :user }

  before do
    ENV['B3_API_KEY'] = '12345678901234567890'
  end

  describe 'deactivate' do
    it 'happy case' do
      post :deactivate, params: { b3_api_key: '12345678901234567890', id: user.id}
      expect(response.status).to eq 200
      json = JSON.parse response.body
      expect(json['success']).to eq 'ok'
      expect(user.reload.deactivated_at).to be_present
    end

    it 'cannot deactivate deactivated user' do
      user.update(deactivated_at: DateTime.now)
      post :deactivate, params: { b3_api_key: '12345678901234567890', id: user.id}
      expect(response.status).to eq 404
    end

    it 'incorrect key' do
      post :deactivate, params: { b3_api_key: '09876543210987654321', id: user.id}
      expect(response.status).to eq 403
      expect(user.reload.deactivated_at).to_not be_present
    end

    it 'blank key' do
      post :deactivate, params: { b3_api_key: '', id: user.id}
      expect(response.status).to eq 403
      expect(user.reload.deactivated_at).to_not be_present
    end

    it 'nil key' do
      post :deactivate, params: { id: user.id}
      expect(response.status).to eq 403
      expect(user.reload.deactivated_at).to_not be_present
    end
  end

  describe 'activate' do
    before do
      user.update(deactivated_at: DateTime.now)
    end

    it 'happy case' do
      post :reactivate, params: { b3_api_key: '12345678901234567890', id: user.id}
      expect(response.status).to eq 200
      json = JSON.parse response.body
      expect(json['success']).to eq 'ok'
      expect(user.reload.deactivated_at).to_not be_present
    end

    it 'cannot activate activated user' do
      user.update(deactivated_at: nil)
      post :reactivate, params: { b3_api_key: '12345678901234567890', id: user.id}
      expect(response.status).to eq 404
    end
  end
end
