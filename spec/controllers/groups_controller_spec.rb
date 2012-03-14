require 'spec_helper'

describe GroupsController do
  let(:group) { stub_model(Group) }
  let(:user)  { stub_model(User) }
  
  before :each do
    #Group.stub(:find).with(group.id.to_s).and_return(group)
    #group.stub(:can_be_edited_by?).with(user).and_return(true)
    #User.stub(:find).with(user.id.to_s).and_return(user)
  end
  
  context "signed in user, admin of a group" do
    before :each do
      #group.stub(:has_admin_user?).with(user).and_return(true)
      #sign_in user
    end
    
    it "can add a user tag" do
      #TODO AC: working on first mock test
      tag_attrs = "testytag"
      
      #Group.should_receive(:add_user_tag).with(tag_attrs).and_return(group.tag)
      
      #post :add_user_tag, id: group.id, user_id: user.id, tag: tag_attrs

      #response.should be_redirect
    end
    
  end
  
  context "as a logged in user" do
    before :each do
      @user = User.make!
      sign_in @user
    end
    context "existing group" do
      before :each do
        @group = Group.make!
      end
      context "a group admin" do
        before :each do
          @group.add_admin!(@user)
        end
        it "can get all group tags" do
          #TODO AC in progress: get group_tags missing template - StackO says to create the view
          post :add_user_tag, id: @group.id, user_id: @user.id, tag: "testytag"
          #get :group_tags, id: group.id, q: "test"
          #response.should include("testytag")
        end
        it "get user group tags" do
          #TODO AC in progress: get group_tags missing template - StackO says to create the view
          post :add_user_tag, id: @group.id, user_id: @user.id, tag: "testytag"
          #get :user_group_tags, id: @group.id, q: "test"
          #response.should include("testytag")
        end
        it "can add a user tag" do
          post :add_user_tag, id: @group.id, user_id: @user.id, tag: "testytag"
          @user.group_tags.find_by_name("testytag").name.should include("testytag")
        end
        it "can add a user tag and doesn't explode when being called 3 times" do
          post :add_user_tag, id: @group.id, user_id: @user.id, tag: "testytag"
          post :add_user_tag, id: @group.id, user_id: @user.id, tag: "testytag2"
          post :add_user_tag, id: @group.id, user_id: @user.id, tag: "testytag3"
          @user.group_tags.find_by_name("testytag").name.should include("testytag")
          @user.group_tags.find_by_name("testytag2").name.should include("testytag2")
          @user.group_tags.find_by_name("testytag3").name.should include("testytag3")
        end
        it "can delete a user tag" do
          post :add_user_tag, id: @group.id, user_id: @user.id, tag: "testytag"
          @user.group_tags.first.name.should include("testytag")
          post :delete_user_tag, id: @group.id, tag: "testytag", user_id: @user.id
          @user.group_tags.first.should be_nil
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
