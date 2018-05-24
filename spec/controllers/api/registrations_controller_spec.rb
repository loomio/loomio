require 'rails_helper'

describe API::RegistrationsController do
  let(:registration_params) {{
    name: "Jon Snow",
    email: "jon@snow.com",
    legal_accepted: true
  }}

  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  describe 'create' do
    let(:pending_membership) { create :membership, user: User.new(email: registration_params[:email]) }
    let(:pending_identity)   { create :facebook_identity, email: registration_params[:email] }

    it 'creates a new user' do
      expect { post :create, params: { user: registration_params } }.to change { User.count }.by(1)
      expect(response.status).to eq 200
      u = User.last
      expect(u.name).to eq registration_params[:name]
      expect(u.email).to eq registration_params[:email]
      expect(u.legal_accepted_at).to be_present
    end

    it 'requires acceptance of legal' do
      registration_params.delete(:legal_accepted)
      post :create, params: { user: registration_params }
      expect(response.status).to eq 422
    end

    it 'sends a login email' do
      Clients::Recaptcha.any_instance.stub(:validate) { true }
      expect { post :create, params: { user: registration_params } }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'logs in immediately if pending invitation is present' do
      session[:pending_membership_token] = pending_membership.token
      expect { post :create, params: { user: registration_params.except(:recaptcha) } }.to change { User.count }.by(1)
      u = User.last
      expect(u.name).to eq registration_params[:name]
      expect(u.email).to eq registration_params[:email]
    end

    it 'logs in immediately if pending identity is present' do
      session[:pending_identity_id] = pending_identity.id
      expect { post :create, params: { user: registration_params.except(:recaptcha) } }.to change { User.count }.by(1)
      u = User.last
      expect(u.name).to eq registration_params[:name]
      expect(u.email).to eq registration_params[:email]
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
