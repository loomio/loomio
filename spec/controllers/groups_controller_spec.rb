require 'spec_helper'

describe GroupsController do
  context "as a logged in user" do
    before :each do
      @user = User.make!
      sign_in @user
    end
    context "existing group" do
      before :each do
        @group = Group.make!
        @group.owner = @user
      end
      it "shows a group" do
        get :show, :id => @group.id
        response.should be_success
      end
      it "shows an edit group form" do
        get :edit, :id => @group.id
        response.should be_success
      end

    end
    it "shows a new group form" do
      get :new
      response.should be_success
    end

    it "creates a group" do
      @group = Group.make
      post :create, :group => @group.attributes
      assigns(:group).owner.should == @user
      response.should be_redirect
    end
  end
end
