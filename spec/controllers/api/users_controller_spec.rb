require 'rails_helper'
describe API::UsersController do

  let(:user) { create :user }
  let(:another_user) { create :user }

  before do
    sign_in user
  end

  # describe 'update' do
  #   context 'success' do
  #     it "updates a discussion" do
  #       post :update, id: user.id, user: user_params, format: :json
  #       expect(response).to be_success
  #       expect(user.reload.dashboard_filter).to eq user_params[:dashboard_filter]
  #     end
  #   end

  #   context 'failures' do
  #     it "responds with an error when there are unpermitted params" do
  #       user_params[:dontmindme] = 'wild wooly byte virus'
  #       put :update, id: user.id, user: user_params
  #       expect(JSON.parse(response.body)['exception']).to eq 'ActionController::UnpermittedParameters'
  #     end

  #     it "responds with an error when the user is unauthorized" do
  #       sign_in another_user
  #       put :update, id: user.id, user: user_params
  #       expect(JSON.parse(response.body)['exception']).to eq 'CanCan::AccessDenied'
  #     end
  #   end
  # end

end
