require 'spec_helper'

describe PersonaController do

  describe "POST verify" do
    let(:validator) { stub(:validator) }

    before do
      PersonaAssertionValidator.stub(:new).and_return(validator)
    end

    context 'valid assertion' do
      before do
        validator.should_receive(:valid?).and_return(true)
      end

      context 'recognised persona' do
        let(:user) { stub_model(User) }
        let(:persona) {stub(:persona, user: user) }

        before do
          Persona.should_receive(:for_email).and_return(persona)
        end

        it 'signs in the user' do
          controller.should_receive(:sign_in).with(:user, user)
          post :verify
        end

        it 'redirects a path that should be correct' do
          post :verify
          response.should be_redirect
        end
      end

      context 'unrecognised persona' do
        before do
          validator.should_receive(:valid?).and_return(true)
        end
        it 'sets persona_id in sessions'
        it 'redirects to signup or sign in'
      end
    end

    context 'invalid assertion' do
      before do
        validator.should_receive(:valid?).and_return(false)
      end

      it 'redirects to login page' do
        post :verify
        response.should redirect_to new_user_session_path
        flash[:error].should == I18N.t(:persona_validation_failed)
      end
    end
  end
end
