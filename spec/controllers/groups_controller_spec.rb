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
      end
      context "a group member" do
        before :each do
          @group.add_member!(@user)
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
      context "a requested member" do
        before :each do
          @group.add_request!(@user)
        end
        it "shows a group" do
          get :show, :id => @group.id
          response.should redirect_to(groups_url)
        end
        it "shows an edit group form" do
          get :edit, :id => @group.id
          response.should redirect_to(groups_url)
        end
      end
      context "not a group member" do
        it "shows a group" do
          get :show, :id => @group.id
          response.should redirect_to(request_membership_group_url)
        end
        it "shows an edit group form" do
          get :edit, :id => @group.id
          response.should redirect_to(request_membership_group_url)
        end
      end

    end
    it "shows all groups" do
      get :index
      response.should be_success
    end

    it "shows a new group form" do
      get :new
      response.should be_success
    end

    it "creates a group" do
      @group = Group.make!
      post :create, :group => @group.attributes
      assigns(:group).users.should include(@user)
      assigns(:group).admins.should include(@user)
      response.should be_redirect
    end
  end
end
