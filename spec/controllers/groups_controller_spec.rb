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

    context "admin of a group" do
      before :each do
        group.stub(:can_be_edited_by?).with(user).and_return(true)
      end

      it "can add a user tag" do
        old_tags = ["testytag", "testy"]
        new_tag = "newww"
        new_tags = "testytag,testy,newww"

        user.should_receive(:group_tags_from).with(group).and_return(old_tags)
        group.should_receive(:tag).with user, with: new_tags, on: :group_tags

        post :add_user_tag, id: group.id, user_id: user.id, tag: new_tag
      end

      it "can get all group tags" do
        group.stub_chain(:owned_tags, :where)
          .and_return([stub(id: 1, name: "testytag")])

        get :group_tags, format: :json, id: group.id, q: "test"

        response.body.should == [{ id: 1, name: "testytag" }].to_json
      end

      it "get user group tags" do
        group.should_receive(:get_user_tags).with(user)
          .and_return([stub(id: 1, name: "testy")])

        get :user_group_tags, format: :json, id: group.id, user_id: user.id

        response.body.should == [{ id: 1, name: "testy" }].to_json
      end

      it "can add a user tag and doesn't explode when being called 3 times" do
        pending "refactor test to use stubs"
        post :add_user_tag, id: group.id, user_id: user.id, tag: "testytag"
        post :add_user_tag, id: group.id, user_id: user.id, tag: "testytag2"
        post :add_user_tag, id: group.id, user_id: user.id, tag: "testytag3"
        user.group_tags.find_by_name("testytag").name.should include("testytag")
        user.group_tags.find_by_name("testytag2").name.should include("testytag2")
        user.group_tags.find_by_name("testytag3").name.should include("testytag3")
      end

      it "can delete a user tag" do
        group.should_receive(:delete_user_tag).with(user, "testytag")

        post :delete_user_tag, id: group.id, tag: "testytag", user_id: user.id
      end
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
