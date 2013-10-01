require 'spec_helper'

describe Users::OmniauthCallbacksController do
  describe "POST all" do

    before do
      OmniauthIdentity.should_receive(:from_omniauth).and_return(identity)
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context 'recognised identity' do
      let(:user) { stub_model(User) }
      let(:identity) {stub(:identity, user: user) }

      it 'signs in the user' do
        controller.should_receive(:sign_in).with(:user, user)
        post :all
        response.should be_redirect
      end

    end

    context 'unrecognised persona' do
      let(:identity) {stub(:identity, user: nil, id: 1, email: 'test@example.com') }

      before do
        post :all
      end

      it 'sets persona_id in session' do
        session[:omniauth_identity_id].should == identity.id
        response.should be_redirect
      end
    end
  end
end
