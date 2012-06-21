require 'spec_helper'

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
    end
    context "group viewable by members" do
      before :each do
        @group = Group.make!(viewable_by: :members)
      end
      context "a group admin" do
        before :each do
          @group.add_admin!(@user)
        end
        it "can update the group" do
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
        it "gets a new subgroup form" do
          get :add_subgroup, :id => @group.id
          response.should be_success
        end
      end
      context "a non-member" do
        before :each do
          @previous_url = groups_url
          request.env["HTTP_REFERER"] = @previous_url
        end
        it "viewing a group should redirect to private message page" do
          get :show, :id => @group.id
          response.should render_template('private_or_not_found')
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
      @group.add_member! @user
      @subgroup = Group.make(:parent => @group)

      post :create, :group => @subgroup.attributes

      assigns(:group).parent.should eq(@group)
      assigns(:group).users.should include(@user)
      assigns(:group).admins.should include(@user)
      response.should redirect_to(group_url(assigns(:group)))
    end

    it "adds multiple members" do
      group = Group.make!
      group.add_admin! @user
      user2 = User.make!
      user3 = User.make!

      post :add_members, id: group.id,
        "user_#{user2.id}"  => 1, "user_#{user3.id}" => 1

      group.users.should include(user2)
      group.users.should include(user3)
    end
  end
end
