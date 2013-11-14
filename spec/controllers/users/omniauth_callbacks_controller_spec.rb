require 'spec_helper'

describe Users::OmniauthCallbacksController do
  describe "POST all" do
    let(:user) { stub_model(User) }

    before do
      OmniauthIdentity.should_receive(:from_omniauth).and_return(identity)
      @request.env["devise.mapping"] = Devise.mappings[:user]
    end

    context 'existing identity' do
      let(:identity) {double(:identity, user: user) }

      it 'signs in the user' do
        controller.should_receive(:sign_in).with(:user, user)
        post :all
        response.should be_redirect
      end
    end

    context 'new identity' do
      let(:identity) {double(:identity, user: nil, id: 1, email: 'test@example.com') }

      context 'identity email matches user email' do
        before do
          User.should_receive(:find_by_email).and_return(user)
        end

        it 'signs in the user and sets identity in session' do
          controller.should_receive(:sign_in).with(:user, user)
          post :all
          session[:omniauth_identity_id].should == identity.id
          response.should be_redirect
        end
      end

      context 'unrecognised email' do
        it 'sets identity in session and redirects for loomio auth' do
          post :all
          session[:omniauth_identity_id].should == identity.id
          response.should be_redirect
        end
      end
    end
  end
end
