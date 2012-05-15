require 'spec_helper'

# NOTE (Jon): Lots of these specs should be
# refactored out of here and into ability_spec.rb
# Basically, we shouldn't be testing permissions in here
describe GroupsController do

  let(:group) { stub_model(Group) }
  let(:user)  { stub_model(User) }

  context "signed in user" do
    before :each do
      User.stub(:find).with(user.id.to_s).and_return(user)
      sign_in user
      Group.stub(:find).with(group.id.to_s).and_return(group)
    end
  end

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
      context "members invitable by members" do
        context "member invites user" do
          it "succeeds"
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
        it "can edit the group" do
          post :update, id: @group.id, group: { name: "New name!" }
          flash[:notice].should match("Group was successfully updated.")
          response.should be_redirect
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
        it "shows a new subgroup form" do
          get :add_subgroup, :group_id => @group.id
          response.should be_success
        end
      end
      context "a requested member" do
        before :each do
          @group.add_request!(@user)
          @previous_url = root_url
          request.env["HTTP_REFERER"] = @previous_url
        end
        it "viewing a group should redirect to root url" do
          get :show, :id => @group.id
          response.should redirect_to(root_url)
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

    it "shows a new group form" do
      get :new
      response.should be_success
    end

    it "creates a group" do
      @group = Group.make
      post :create, :group => @group.attributes
      assigns(:group).users.should include(@user)
      assigns(:group).admins.should include(@user)
      response.should redirect_to(group_url(assigns(:group)))
    end

    it "creates a subgroup" do
      @group = Group.make!
      @subgroup = Group.make(:parent => @group)

      post :create, :group => @subgroup.attributes

      assigns(:group).parent.should eq(@group)
      assigns(:group).users.should include(@user)
      assigns(:group).admins.should include(@user)
      response.should redirect_to(group_url(assigns(:group)))
    end

    it "adds multiple members" do
      pending "still getting this working"
      @group = Group.make!
      @group.add_member! @user
      @user2 = User.make!
      @user3 = User.make!

      post :add_members, id: @group.id # Add members here

      @group.users.should include(@user2)
      @group.users.should include(@user3)
    end
  end
end
