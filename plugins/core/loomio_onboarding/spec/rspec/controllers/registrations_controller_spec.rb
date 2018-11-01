require 'rails_helper'

describe API::RegistrationsController do
  let(:registration_params) {{
    name: "Jon Snow",
    email: "jon@snow.com",
    legal_accepted: true
  }}

  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  describe 'create' do
    it 'creates a new user' do
      expect { post :create, params: { user: registration_params } }.to change { User.count }.by(1)
      expect(response.status).to eq 200
      u = User.last
      expect(u.name).to eq registration_params[:name]
      expect(u.email).to eq registration_params[:email]
      expect(u.legal_accepted_at).to be_present
    end

    it 'sends two emails after creating a new user' do
      expect { post :create, params: { user: registration_params } }.to change { ActionMailer::Base.deliveries.count }.by(2)
    end

    it 'sends a welcome email with the correct subject after creating a new user' do
      post :create, params: { user: registration_params }
      emails_sent = ActionMailer::Base.deliveries.last(2)
      subjects_of_emails_sent = emails_sent.map { |e| e.subject }
      expect(subjects_of_emails_sent). to include "Welcome to Loomio!"
    end

    it 'welcome email is sent to the right user' do
      post :create, params: { user: registration_params }
      emails_sent = ActionMailer::Base.deliveries.last(2)
      welcome_email = emails_sent.select { |e| e.subject == "Welcome to Loomio!" }.first
      expect(welcome_email.to[0]).to eq registration_params[:email]
    end
  end
end
