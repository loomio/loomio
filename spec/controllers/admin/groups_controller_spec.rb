require 'spec_helper'

describe Admin::GroupsController do
  before :each do
    @user = User.make!
    sign_in @user
  end

  context "logged-in admin user views groups" do
    it "should display all groups" do
      @user.update_attribute :admin, true
      get :index
      response.should be_success
    end
  end
  context "logged-in non-admin user views groups" do
    it "should redirect to user's groups index" do
      get :index
      response.should be_redirect
    end
  end
  context "logged-out user views groups" do
    it "should redirect to login page" do
      sign_out @user
      get :index
      response.should redirect_to(new_user_session_url)
    end
  end
end
