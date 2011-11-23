require 'spec_helper'

describe GroupsController do
  context "as a logged in user" do
    before :each do
      @user = User.make!
      sign_in @user
      @group = Group.make!
    end

    it "shows a group" do
      get :show, :id => @group.id
      response.should be_success
    end

    it "shows a new group form" do
      get :new
      response.should be_success
    end

    it "shows a edit group form" do
      get :edit
      response.should be_success
    end
    
    it "creates a group" do
      post :create, :group => @group.attributes 
      assigns(:group).user.should == @user
      response.should be_redirect
    end
  end
end
