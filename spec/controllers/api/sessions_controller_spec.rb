require 'rails_helper'

describe API::SessionsController do
  describe 'create' do
    let(:user) { create :user, email: "verified@example.com", email_verified: true, password: nil }
    let(:unverified_user) { create :user, email_verified: false, email: "unverified@example.com" }
    let(:token) { create :login_token }

    describe 'via password' do
      before do
        request.env["devise.mapping"] = Devise.mappings[:user]
      end

      it 'signs in with password' do
        user.update(password: "s3curepassword123")
        post :create, params: {user: {email: "verified@example.com", password: "s3curepassword123"}}
        expect(response.status).to eq 200
        json = JSON.parse response.body
        expect(json['current_user_id']).to eq user.id
      end

      it 'does not sign in a blank password' do
        post :create, params: {user: {email: "verified@example.com", password: ""}}
        expect(response.status).to eq 401
      end

      it 'does not sign in a nil password' do
        post :create, params: {user: {email: "verified@example.com", password: nil}}
        expect(response.status).to eq 401
      end
    end

    describe 'via token' do
      before do
        session[:pending_login_token] = token.token
        request.env["devise.mapping"] = Devise.mappings[:user]
      end

      it 'signs in a user' do
        token.update(user: user)
        post :create
        expect(token.reload.used).to eq true
        expect(response.status).to eq 200
        json = JSON.parse response.body
        expect(json['current_user_id']).to eq user.id
      end

      it 'does not sign in a user with a used token' do
        token.update(user: user, used: true)
        post :create
        expect(response.status).to eq 401
      end

      it 'does not sign in a user with an expired token' do
        token.update(user: user, created_at: 25.hours.ago)
        post :create
        expect(response.status).to eq 401
      end

      it 'does not sign in a user with an invalid token id' do
        session[:pending_login_token] = 'notatoken'
        post :create
        expect(response.status).to eq 401
      end

      it 'finds a verified user to sign in' do
        token.update(user: user)
        unverified_user
        post :create
        expect(response.status).to eq 200
        json = JSON.parse response.body
        expect(json['current_user_id']).to eq user.id
      end

      it 'signs in an unverified user' do
        token.update(user: unverified_user)
        post :create
        expect(response.status).to eq 200
        json = JSON.parse response.body
        expect(json['current_user_id']).to eq unverified_user.id
      end
    end
  end
end
