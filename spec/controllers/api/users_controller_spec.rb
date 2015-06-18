require 'rails_helper'
describe API::UsersController do

  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:user_params) { { name: "new name", email: "new@email.com" } }

  before do
    sign_in user
  end

  describe 'update_profile' do
    context 'success' do
      it "updates a users profile" do
        post :update_profile, user: user_params, format: :json
        expect(response).to be_success
        expect(user.reload.email).to eq user_params[:email]
        json = JSON.parse(response.body)
        user_emails = json['users'].map { |v| v['email'] }
        expect(user_emails).to include user_params[:email]
      end
    end

    context 'failures' do
      it "responds with an error when there are unpermitted params" do
        user_params[:dontmindme] = 'wild wooly byte virus'
        put :update_profile, user: user_params, format: :json
        expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
      end
    end
  end

end
