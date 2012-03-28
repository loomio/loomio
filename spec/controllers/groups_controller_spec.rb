require 'spec_helper'

describe GroupsController do
  context "logged in user" do
    before :each do
      @user = User.make!
      sign_in @user
    end
    context "group viewable by everyone" do
      before :each do
        @group = Group.make!(viewable_by: :everyone)
      end
      context "non-member views group" do
        it "should show group page" do
          get :show, :id => @group.id
          response.should be_success
        end
      end
      context "member views group" do
        it "should show group page" do
          @group.add_member!(@user)
          get :show, :id => @group.id
          response.should be_success
        end
      end
    end
    context "group viewable by members" do
      before :each do
        @group = Group.make!(viewable_by: :members)
      end
      context "a group admin" do
        before :each do
          @group.add_admin!(@user)
        end
        it "can add a user tag" do
          post :add_user_tag, id: @group.id, tag: "testytag", user_id: @user.id
          post :add_user_tag, id: @group.id, tag: "testytag2", user_id: @user.id
          post :add_user_tag, id: @group.id, tag: "testytag3", user_id: @user.id
          #debugger
          @user.group_tags.find_by_name("testytag").name.should include("testytag")
          @user.group_tags.find_by_name("testytag2").name.should include("testytag2")
          @user.group_tags.find_by_name("testytag3").name.should include("testytag3")
        end
        it "can delete a user tag" do
          post :add_user_tag, id: @group.id, tag: "testytag", user_id: @user.id
          @user.group_tags.first.name.should include("testytag")
          post :delete_user_tag, id: @group.id, tag: "testytag", user_id: @user.id
          @user.group_tags.first.should be_nil
        end
        it "can visit the invite a new member page" do
          get :invite_member, id: @group.id
          response.should be_success
        end
      end
      context "a group member" do
        before :each do
          @group.add_member!(@user)
        end
        it "shows a group" do
          get :show, :id => @group.id
          response.should be_success
        end
      end
      context "a requested member" do
        before :each do
          @group.add_request!(@user)
          @previous_url = groups_url
          request.env["HTTP_REFERER"] = @previous_url
        end
        it "viewing a group should redirect to previous url" do
          get :show, :id => @group.id
          response.should redirect_to(@previous_url)
        end
        it "editing a group should redirect to previous url" do
          get :edit, :id => @group.id
          response.should redirect_to(@previous_url)
        end
      end
      context "a non-member" do
        before :each do
          @previous_url = groups_url
          request.env["HTTP_REFERER"] = @previous_url
        end
        it "viewing a group should redirect to request page" do
          get :show, :id => @group.id
          response.should redirect_to(request_membership_group_url)
        end
        it "editing a group should redirect to previous url" do
          get :edit, :id => @group.id
          response.should redirect_to(@previous_url)
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
