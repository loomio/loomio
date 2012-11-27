require 'spec_helper'

describe GroupsController do
  let(:group) { stub_model(Group) }
  let(:user)  { stub_model(User) }

  context "logged in user" do
    before :each do
      @user = create(:user)
      sign_in @user
    end

    context "group viewable by everyone" do
      before :each do
        @group = create(:group, viewable_by: :everyone)
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
        @group = create(:group, viewable_by: :members)
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
      user = build(:user, :email => "contact@loomio.org")
      user.save
      @group = build(:group)
      post :create, :group => @group.attributes
      assigns(:group).users.should include(@user)
      assigns(:group).admins.should include(@user)

      assigns(:group).creator.should == @user
      response.should redirect_to(group_url(assigns(:group)))
    end

    it "creates a subgroup" do
      user = build(:user, :email => "contact@loomio.org")
      user.save
      @group = create(:group)
      @group.add_member! @user
      @subgroup = build(:group, :parent => @group)

      post :create, :group => @subgroup.attributes

      assigns(:group).parent.should eq(@group)
      assigns(:group).users.should include(@user)
      assigns(:group).admins.should include(@user)
      response.should redirect_to(group_url(assigns(:group)))
    end

    describe "#edit description" do
      before do
        controller.stub(:authorize!).and_return(true)
        controller.stub(:can?).with(:edit_description, group).and_return(true)
        Group.stub(:find).and_return(group)
        group.stub(:save!).and_return(true)
      end
      it "assigns description to the model" do
        group.should_receive(:description=).with "blah"
        xhr :post, :edit_description,
          :id => "12051",
          :description => "blah"
      end
      it "saves the model" do
        group.should_receive :save!
        xhr :post, :edit_description,
          :id => group.id,
          :description => "blah"
      end
    end

    describe "#edit privacy" do
      before do
        controller.stub(:authorize!).and_return(true)
        controller.stub(:can?).with(:edit_privacy, group).and_return(true)
        Group.stub(:find).and_return(group)
        group.stub(:save!).and_return(true)
      end
      it "assigns viewable_by to the model" do
        group.should_receive(:viewable_by=).with "member"
        xhr :post, :edit_privacy,
          :id => "12051",
          :viewable_by => "member"
      end
      it "saves the model" do
        group.should_receive :save!
        xhr :post, :edit_privacy,
          :id => group.id,
          :viewable_by => "member"
      end
    end

    describe "add_members" do
      before do
        @user2 = create(:user)
        @user3 = create(:user)
        @group = create(:group)
        @group.add_admin! @user
        @group.stub(:add_member!)
        Group.stub(:find).with(@group.id.to_s).and_return(@group)
        Event.stub(:user_added_to_group!)
      end

      it "adds members to group" do
        @group.should_receive(:add_member!).with(@user2, @user)
        @group.should_receive(:add_member!).with(@user3, @user)

        post :add_members, id: @group.id,
          "user_#{@user2.id}" => 1, "user_#{@user3.id}" => 1
      end
    end

    describe "archiving a group" do
      before do
        @group = create(:group)
        @group.add_admin! @user
        @subgroup = create(:group, :parent => @group)
        @subgroup.add_member! @user
        post :archive, :id => @group.id
      end
      it "sets archived_at field on the group" do
        assigns(:group).archived_at.should_not == nil
      end
      it "sets archived_at on the group's subgroups" do
        @subgroup.reload
        @subgroup.archived_at.should_not == nil
      end
      it "sets flash response" do
        flash[:success].should =~ /Group archived successfully/
      end
      it "redirects to the dashboard" do
        response.should redirect_to(:dashboard)
      end
    end

    describe "viewing an archived group" do
      before do
        @group = create(:group)
        @group.archived_at = Time.now
        @group.save
      end
      it "throws an error" do
        lambda { get :show, :id => @group.id }.should raise_error
      end
    end

    describe "#email_members" do
      before do
        @previous_url = group_url group
        request.env["HTTP_REFERER"] = @previous_url
        Group.stub(:find).with(group.id.to_s).and_return(group)
        controller.stub(:authorize!).and_return(true)
        controller.stub(:can?).with(:email_members, group).and_return(true)
        @email_subject = "i have something really important to say!"
        @email_body = "goobly"
        GroupMailer.stub(:delay).and_return(GroupMailer)
        GroupMailer.stub(:deliver_group_email)
        @mailer_args = { :id => group.id, :group_email_body => @email_body,
                         :group_email_subject => @email_subject }
      end

      it "sends email to group" do
        GroupMailer.should_receive(:deliver_group_email).
          with(group, @user, @email_subject, @email_body)
        post :email_members, @mailer_args
      end

      it "populates flash notice" do
        post :email_members, @mailer_args
        flash[:success].should == "Emails sending."
      end

      it "redirects to previous page" do
        post :email_members, @mailer_args
        response.should redirect_to(@previous_url)
      end
    end
  end
end
