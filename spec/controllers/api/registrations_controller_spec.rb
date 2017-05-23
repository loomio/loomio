require 'rails_helper'

describe API::RegistrationsController do
  let(:registration_params) {{
    name: "Jon Snow",
    email: "jon@snow.com",
    recaptcha: "notarobot"
  }}

  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  describe 'create' do
    it 'creates a new user' do
      Clients::Recaptcha.any_instance.stub(:validate) { true }
      expect { post :create, user: registration_params }.to change { User.count }.by(1)
      expect(response.status).to eq 200
      u = User.last
      expect(u.name).to eq registration_params[:name]
      expect(u.email).to eq registration_params[:email]
    end

    it 'sends a login email' do
      Clients::Recaptcha.any_instance.stub(:validate) { true }
      expect { post :create, user: registration_params }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'does not create a new user if recaptcha is not present' do
      registration_params[:recaptcha] = ''
      expect { post :create, user: registration_params }.to raise_error { ActionController::ParameterMissing }
    end

    it 'does not create a new user if the recaptcha is invalid' do
      Clients::Recaptcha.any_instance.stub(:validate) { false }
      expect { post :create, user: registration_params }.to_not change { User.count }
      expect(response.status).to eq 422
    end
  end
end
