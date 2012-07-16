require 'spec_helper'

describe NotificationsController do
  let(:user) { User.make! }
  let(:notifications) { [stub_model(Notification)] }

  before do
    sign_in user
    user.stub(:notifications => notifications)
    controller.stub(:get_notifications)
  end

  describe "#index" do
    before { get :index }

    it { response.should be_success }

    it { assigns(:notifications).should == notifications }

  end

  describe "#mark_as_read" do
    it "marks user's notifications as read" do
      user.should_receive(:mark_notifications_as_viewed!).
        with(notifications[0].id.to_s)
      post :mark_as_viewed, :latest_viewed => notifications[0].id
    end
  end
end
