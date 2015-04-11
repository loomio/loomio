require 'rails_helper'
describe API::NotificationsController do

  let(:user) { create :user }

  before do
    sign_in user
  end

  describe 'viewed' do
    it 'updates user.notifications_last_viewed_at' do
      user
      expect(user.notifications_last_viewed_at.nil?).to be true
      post :viewed
      user.reload
      expect(user.notifications_last_viewed_at.nil?).to be false
    end
  end
end
