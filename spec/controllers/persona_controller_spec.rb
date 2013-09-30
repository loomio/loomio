require 'spec_helper'

describe PersonaController do
  def response_json
    JSON.parse(response.body)
  end

  describe "POST verify" do
    let(:validator) { stub(:validator, email: 'jim@jam.com') }

    before do
      PersonaValidator.stub(:new).and_return(validator)
    end

    context 'valid assertion' do
      before do
        validator.should_receive(:valid?).and_return(true)
        Persona.should_receive(:for_email).and_return(persona)
      end

      context 'recognised persona' do
        let(:user) { stub_model(User) }
        let(:persona) {stub(:persona, user: user) }

        it 'signs in the user' do
          controller.should_receive(:sign_in).with(:user, user)
          post :verify
        end

        it 'sets redirect_to' do
          post :verify
          response_json['redirect_to'].should_not be_blank
        end
      end

      context 'unrecognised persona' do
        let(:persona) {stub(:persona, user: nil, id: 1, email: 'test@example.com') }

        before do
          post :verify
        end

        it 'sets persona_id in session' do
          session[:persona_id].should == persona.id
        end

        it 'redirects to signup or sign in' do
          response_json['redirect_to'].should == new_user_registration_path
        end
      end
    end

    context 'invalid assertion' do
      before do
        validator.should_receive(:valid?).and_return(false)
      end

      it 'redirects to login page' do
        post :verify
        response_json['redirect_to'].should == root_path
        flash[:error].should == I18n.t(:persona_validation_failed)
      end
    end
  end
end
