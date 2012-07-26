require 'spec_helper'

describe GroupsController do
  let(:group) { stub_model(Group) }

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
        context "viewing new proposal form" do
          it "renders a new motion page" do
            get :new_motion, :id => @group.id
            response.should render_template("groups/new_motion")
          end
        end

        context "creating a new proposal" do
          before do
            @discussion = Discussion.new
            @user.authored_discussions.stub(:create!).and_return(@discussion)
            @motion = stub_model(Motion)
            @discussion.motions.stub(:new).and_return(@motion)
            @motion.stub(:save).and_return(true)
            @motion_args = { :id => @group.id,
                             :motion => { "name" => "Motion title" } }
          end

          it "creates a discussion with the new motion name" do
            @user.authored_discussions.should_receive(:create!).
              with(:group_id => @group.id, :title =>  "Motion title")
            post :create_motion, @motion_args
          end

          it "creates a new motion" do
            @motion = stub_model(Motion)
            @discussion.motions.should_receive(:new).with(@motion_args[:motion]).
              and_return(@motion)
            @motion.should_receive(:author=).with(@user)
            @motion.should_receive(:save).and_return(true)
            post :create_motion, @motion_args
          end

          it "populates flash success message" do
            post :create_motion, @motion_args
            flash[:success].should == "Proposal has been created."
          end

          it "redirects user to discussion page" do
            post :create_motion, @motion_args
            response.should redirect_to(@discussion)
          end

          context "fails to create a new motion" do
            before do
              @motion.stub(:save).and_return(false)
              @previous_url = new_motion_group_path(@group)
              request.env["HTTP_REFERER"] = @previous_url
            end

            it "redirects to previous url" do
              post :create_motion, @motion_args

              response.should redirect_to(@previous_url)
            end

            it "populates flash error message" do
              post :create_motion, @motion_args
              flash[:error].should == "Proposal could not be created."
            end
          end
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

      assigns(:group).creator.should == @user
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

    describe "#email_members" do
      before do
        @previous_url = group_url group
        request.env["HTTP_REFERER"] = @previous_url
        Group.stub(:find).with(group.id.to_s).and_return(group)
        controller.stub(:authorize!).and_return(true)
        controller.stub(:can?).with(:email_members, group).and_return(true)
        @email_subject = "i have something really important to say!"
        @email_body = "goobly"
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
        flash[:success].should == "Email sent."
      end

      it "redirects to previous page" do
        post :email_members, @mailer_args
        response.should redirect_to(@previous_url)
      end
    end
  end
end
