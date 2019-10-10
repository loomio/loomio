require 'rails_helper'

describe API::RegistrationsController do
  let(:registration_params) {{
    name: "Jon Snow",
    email: "jon@snow.com",
    legal_accepted: true
  }}

  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  describe 'create' do
    let(:login_token)        { create :login_token, user: User.create(email: registration_params[:email], email_verified: false) }
    let(:pending_membership) { create :membership, user: User.create(email: registration_params[:email], email_verified: false) }
    let(:pending_identity)   { create :facebook_identity, email: registration_params[:email] }

    it 'creates a new user' do
      expect { post :create, params: { user: registration_params } }.to change { User.count }.by(1)
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['signed_in']).to be false
      u = User.find_by(email: registration_params[:email])
      expect(u.name).to eq registration_params[:name]
      expect(u.email).to eq registration_params[:email]
      expect(u.legal_accepted_at).to be_present
    end

    it "sign up via email for existing user (email_verified = false)" do
      u = User.create(email: registration_params[:email], email_verified: false)
      expect { post :create, params: { user: registration_params } }.to change { User.count }.by(0)
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['signed_in']).to be false
      u.reload
      expect(u.name).to eq registration_params[:name]
      expect(u.email).to eq registration_params[:email]
      expect(u.legal_accepted_at).to be_present
    end

    it "signup via membership" do
      session[:pending_membership_token] = pending_membership.token
      expect { post :create, params: { user: registration_params } }.to change { User.count }.by(0)
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['signed_in']).to be true
      u = User.find_by(email: registration_params[:email])
      expect(u.name).to eq registration_params[:name]
      expect(u.email).to eq registration_params[:email]
      expect(u.legal_accepted_at).to be_present
    end

    it "signup via membership with different email address" do
      session[:pending_membership_token] = pending_membership.token
      registration_params[:email] = "changed@example.com"
      expect { post :create, params: { user: registration_params } }.to change { User.count }.by(0)
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['signed_in']).to be false
      u = User.find_by(email: registration_params[:email])
      expect(u.name).to eq registration_params[:name]
      expect(u.email).to eq registration_params[:email]
      expect(u.legal_accepted_at).to be_present
    end

    it "signup via membership of another user" do
      pending_membership.user.update(email_verified: true)
      session[:pending_membership_token] = pending_membership.token
      registration_params[:email] = "newuser@example.com"
      expect { post :create, params: { user: registration_params } }.to change { User.count }.by(1)
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['signed_in']).to be false
      u = User.find_by(email: registration_params[:email])
      expect(u.name).to eq registration_params[:name]
      expect(u.email).to eq registration_params[:email]
      expect(u.legal_accepted_at).to be_present
    end

    it "signup via login token" do
      session[:pending_login_token] = login_token.token
      expect { post :create, params: { user: registration_params } }.to change { User.count }.by(0)
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['signed_in']).to be true
      u = User.find_by(email: registration_params[:email])
      expect(u.name).to eq registration_params[:name]
      expect(u.email).to eq registration_params[:email]
      expect(u.legal_accepted_at).to be_present
    end

    # it 'logs in immediately if pending identity is present' do
    #   session[:pending_identity_id] = pending_identity.id
    #   expect { post :create, params: { user: registration_params.except(:recaptcha) } }.to change { User.count }.by(0)
    #   expect(JSON.parse(response.body)['signed_in']).to be true
    #   u = User.find_by(email: registration_params[:email])
    #   expect(u.name).to eq registration_params[:name]
    #   expect(u.email).to eq registration_params[:email]
    # end

    it 'requires acceptance of legal' do
      registration_params.delete(:legal_accepted)
      post :create, params: { user: registration_params }
      expect(response.status).to eq 422
    end

    it 'sends a login email and a welcome email' do
      Clients::Recaptcha.any_instance.stub(:validate) { true }
      expect { post :create, params: { user: registration_params } }.to change { ActionMailer::Base.deliveries.count }.by(2)
    end

    describe 'RECAPTCHA env present' do
      before { ENV['RECAPTCHA_APP_KEY'] = 'huzzah' }
      after  { ENV.delete('RECAPTCHA_APP_KEY') }

      it 'validates the recaptcha value' do
        Clients::Recaptcha.any_instance.stub(:validate) { true }
        post :create, params: { user: registration_params }
        expect(response.status).to eq 200
      end

      it 'invalidtes user on recaptcha failure' do
        Clients::Recaptcha.any_instance.stub(:validate) { false }
        post :create, params: { user: registration_params }
        expect(response.status).to eq 422
        json = JSON.parse(response.body)
        expect(json['errors']['recaptcha'][0]).to include "verify that you're not a robot"
      end
    end
  end
end
