require 'rails_helper'

describe ApplicationController do
  let(:user) { FactoryGirl.create(:user) }
  before { sign_in user }

  describe 'GET gone' do
    it 'responds with gone' do
      get :gone
      expect(response.status).to eq 410
      expect(response.body.present?).to eq false
    end
  end
end
