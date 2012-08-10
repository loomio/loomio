require 'spec_helper'

describe NotificationsController do
  let(:user) { User.make! }
  let(:paginator) { double "paginator", :per => notification_results }
  let(:notification_results) { [1,2,3] }
  let(:notifications) { double "notifications", :page => paginator }

  before do
    sign_in user
    user.stub(:notifications => notifications)
    controller.stub(:get_notifications)
  end

  describe "#index" do
    it "responds successfully" do
      get :index
      response.should be_success
    end

    it "assigns and paginates notifications" do
      notifications.should_receive(:page).and_return(paginator)
      paginator.should_receive(:per).with(15).and_return(notification_results)
      get :index
    end
  end

  describe "#mark_as_read" do
    it "marks user's notifications as read" do
      user.should_receive(:mark_notifications_as_viewed!).
        with("999")
      post :mark_as_viewed, :latest_viewed => 999
    end
  end
end
