require 'rails_helper'

describe UsersController do
  describe 'show' do
    it 'redirects to 404 for a user who doesnt exist' do
      get :show, username: :undefined
      expect(response.status).to eq 404
    end
  end
end
