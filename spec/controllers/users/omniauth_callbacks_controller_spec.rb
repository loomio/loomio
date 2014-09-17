#require 'rails_helper'

#describe Users::OmniauthCallbacksController do
  #describe "POST all" do
    #let(:user) { stub_model(User) }

    #before do
      #OmniauthIdentity.should_receive(:from_omniauth).and_return(identity)
      #@request.env["devise.mapping"] = Devise.mappings[:user]
    #end

    #context 'existing identity' do
      #let(:identity) {double(:identity, user: user) }

      #it 'signs in the user with google' do
        #controller.should_receive(:sign_in).with(:user, user)
        #post :google
        #response.should be_redirect      
      #end

      #it 'signs in the user with facebook' do
        #controller.should_receive(:sign_in).with(:user, user)
        #post :facebook
        #response.should be_redirect       
      #end

      #it 'signs in the user with browser_id' do
        #controller.should_receive(:sign_in).with(:user, user)
        #post :browser_id
        #response.should be_redirect 
      #end      
    #end

    #context 'new identity' do
      #let(:identity) {double(:identity, user: nil, id: 1, email: 'test@example.com') }

      #context 'identity email matches user email' do
        #before do
          #User.should_receive(:find_by_email).and_return(user)
        #end

        #it 'signs in the user and sets identity in session with google' do
          #controller.should_receive(:sign_in).with(:user, user)
          #post :google
          #session[:omniauth_identity_id].should == identity.id
          #response.should be_redirect
        #end

        #it 'signs in the user and sets identity in session with facebook' do
          #controller.should_receive(:sign_in).with(:user, user)
          #post :facebook
          #session[:omniauth_identity_id].should == identity.id
          #response.should be_redirect
        #end

        #it 'signs in the user and sets identity in session with browser_id' do
          #controller.should_receive(:sign_in).with(:user, user)
          #post :browser_id
          #session[:omniauth_identity_id].should == identity.id
          #response.should be_redirect
        #end
      #end

      #context 'unrecognised email' do
        #it 'sets identity in session and redirects for loomio auth for google' do
          #post :google
          #session[:omniauth_identity_id].should == identity.id
          #response.should be_redirect
        #end

        #it 'sets identity in session and redirects for loomio auth for facebook' do
          #post :facebook
          #session[:omniauth_identity_id].should == identity.id
          #response.should be_redirect
        #end

        #it 'sets identity in session and redirects for loomio auth for browser_id' do
          #post :browser_id
          #session[:omniauth_identity_id].should == identity.id
          #response.should be_redirect
        #end
      #end
    #end
  #end
#end
