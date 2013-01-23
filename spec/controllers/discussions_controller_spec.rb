require 'spec_helper'

describe DiscussionsController do
  let(:app_controller) { controller }
  let(:user) { stub_model(User) }
  let(:motion) { mock_model(Motion) }
  let(:group) { mock_model(Group) }
  let(:discussion) { stub_model(Discussion,
                                author: user,
                                current_motion: motion,
                                group: group) }

  context "authenticated user" do
    before do
      sign_in user
      app_controller.stub(:authorize!).and_return(true)
      app_controller.stub(:cannot?).with(:show, group).and_return(false)
      Discussion.stub(:find).with(discussion.id.to_s).and_return(discussion)
      Discussion.stub(:new).and_return(discussion)
      User.stub(:find).and_return(user)
      Group.stub(:find).with(group.id.to_s).and_return(group)
    end

    describe "viewing a discussion" do
      it "does not render layout if ajax request"

      context "within a group" do
        it "gets sorted discussions for group" do
          pending "couldnt figure out how to easily stub out kaminari"
          group.should_receive(:discussions_sorted)
          get :index, :group_id => group.id
        end
      end
      context "without specifying a group" do
        it "gets sorted discussions for user with paging" do
          pending "couldnt figure out how to easily stub out kaminari"
          user.should_receive(:discussions_sorted)
          get :index
        end
      end

      context do
        before do
          motion.stub(:votes_graph_ready).and_return([])
          motion.stub(:user_has_voted?).and_return(true)
          motion.stub(:open_close_motion)
          motion.stub(:voting?).and_return(true)
          discussion.stub(:history)
        end
        it "responds with success" do
          get :show, id: discussion.id
          response.should be_success
        end
        it "creates a motion_read_log if there is a current motion"
        it "creates a discussion_read_log"

        it "assigns array with discussion history" do
          discussion.should_receive(:activity).and_return(['fake'])
          get :show, id: discussion.id
          assigns(:activity).should eq(['fake'])
        end
      end
    end

    describe "creating a discussion" do
      before do
        discussion.stub(:add_comment)
        discussion.stub(:save).and_return(true)
        DiscussionMailer.stub(:spam_new_discussion_created)
        @discussion_hash = { group_id: group.id, title: "Shinney" }
      end
      it "does not send email by default" do
        DiscussionMailer.should_not_receive(:spam_new_discussion_created)
        get :create, discussion:
          @discussion_hash.merge({ notify_group_upon_creation: "0" })
      end

      it "displays flash success message" do
        get :create, discussion: @discussion_hash
        flash[:success].should match("Discussion sucessfully created.")
      end

      it "redirects to discussion" do
        get :create, discussion: @discussion_hash
        response.should redirect_to(discussion_path(discussion.id))
      end
    end

    describe "creating a new proposal" do
      it "is successful" do
        get :new_proposal, id: discussion.id
        response.should be_success
      end
      it "renders new motion template" do
        get :new_proposal, id: discussion.id
        response.should render_template("motions/new")
      end
    end

    describe "adding a comment" do
      before do
        Event.stub(:new_comment!)
        @comment = mock_model(Comment, :valid? => true)
        discussion.stub(:add_comment).and_return(@comment)
      end

      it "checks permissions" do
        app_controller.should_receive(:authorize!).and_return(true)
        post :add_comment, comment: "Hello!", id: discussion.id
      end

      it "calls adds_comment on discussion" do
        discussion.should_receive(:add_comment).with(user, "Hello!")
        post :add_comment, comment: "Hello!", id: discussion.id
      end

      context "unsuccessfully" do
        before do
          discussion.stub(:add_comment).
            and_return(mock_model(Comment, :valid? => false))
        end

        it "does not fire new_comment event" do
          Event.should_not_receive(:new_comment!)
          post :add_comment, comment: "Hello!", id: discussion.id
        end

        it "populates flash with error message" do
          post :add_comment, comment: "Hello!", id: discussion.id
          flash[:error].should == "Comment could not be created."
        end
      end
    end

    describe "edit description" do
      before do
        discussion.stub(:set_edit_description_activity!)
        discussion.stub(:save!)
      end

      after do
        xhr :post, :edit_description,
          :id => discussion.id,
          :description => "blah"
      end

      it "assigns description to the model" do
        discussion.should_receive(:set_description!)
      end
    end

    describe "edit title" do
      before do
        discussion.stub(:save!)
      end

      after do
        xhr :post, :edit_title,
          :id => discussion.id,
          :title => "The Butterflys"
      end

      it "assigns title to the model" do
        discussion.should_receive(:title=).with "The Butterflys"
      end
      it "saves the model" do
        discussion.should_receive :save!
      end
      it "creates activity in the events table" do
        discussion.should_receive :fire_edit_title_event
      end
    end

    describe "change version" do
      before do
        @version_item = mock_model(Discussion, :description => "new version", :save! => true)
        @version = mock_model(Version, :item => discussion)
        Version.stub(:find).and_return(@version)
        @version.stub(:reify).and_return(@version_item)
        @version.stub(:save!)
      end

      after do

      end

      it "calls reify on version" do
        @version.should_receive(:reify)
        xhr :post, :update_version,
          :version_id => @version.id
      end
      it "saves the reified version" do
        @version_item.should_receive(:save!)
        xhr :post, :update_version,
          :version_id => @version.id
      end
      it "renders the JS template" do
        xhr :post, :update_version,
          :version_id => @version.id
        response.should render_template("discussions/update_version")
      end
    end
  end
end
